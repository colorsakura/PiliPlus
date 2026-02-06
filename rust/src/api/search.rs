use flutter_rust_bridge::frb;
use crate::models::{SearchVideoResult, SearchVideoItem};
use crate::error::{SerializableError, ApiError};
use crate::services::get_services;
use crate::api::wbi;

/// Build query string from parameters HashMap
fn build_query_string(params: &std::collections::HashMap<String, String>) -> String {
    params
        .iter()
        .map(|(k, v)| format!("{}={}", k, v))
        .collect::<Vec<_>>()
        .join("&")
}

/// Search for videos on Bilibili
#[frb]
pub async fn search_videos(
    keyword: String,
    page: i32,
    order: Option<String>,
    duration: Option<i32>,
    tids: Option<i32>,
) -> Result<SearchVideoResult, SerializableError> {
    let services = get_services().await;

    // Build search parameters as Strings for WBI signing
    let mut params = std::collections::HashMap::new();
    params.insert("search_type".to_string(), "video".to_string());
    params.insert("keyword".to_string(), keyword);
    params.insert("page".to_string(), page.to_string());
    params.insert("page_size".to_string(), "20".to_string());
    params.insert("platform".to_string(), "pc".to_string());
    params.insert("web_location".to_string(), "1430654".to_string());

    if let Some(order_val) = order {
        params.insert("order".to_string(), order_val);
    }
    if let Some(duration_val) = duration {
        params.insert("duration".to_string(), duration_val.to_string());
    }
    if let Some(tids_val) = tids {
        params.insert("tids".to_string(), tids_val.to_string());
    }

    // Add WBI signature
    let (_, _, mixin_key) = wbi::get_wbi_keys_cached().await?;
    wbi::enc_wbi(&mut params, &mixin_key);

    // Build URL with query parameters
    let query_string = build_query_string(&params);
    let url = format!("/x/web-interface/wbi/search/all?{}", query_string);

    // Make HTTP request
    let response: Result<serde_json::Value, ApiError> = services.http.get(&url).await;

    match response {
        Ok(data) => {
            // Parse JSON response
            if let Some(result_data) = data.get("data") as Option<&serde_json::Value> {
                if let Some(result) = result_data.get("result") as Option<&serde_json::Value> {
                    if let Some(results_array) = result.as_array() {
                        // Find video result
                        for item in results_array {
                            if let Some(result_type) = item.get("result_type") as Option<&serde_json::Value> {
                                if result_type == "video" {
                                    if let Some(video_data) = item.get("data") as Option<&serde_json::Value> {
                                        if let Some(videos) = video_data.as_array() {
                                            let items: Vec<SearchVideoItem> = videos
                                                .iter()
                                                .filter_map(|v| serde_json::from_value(v.clone()).ok())
                                                .collect();

                                            let num_results = result_data.get("numResults")
                                                .and_then(|v: &serde_json::Value| v.as_i64())
                                                .unwrap_or(0) as i32;

                                            return Ok(SearchVideoResult {
                                                items,
                                                page,
                                                page_size: 20,
                                                num_results,
                                            });
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Return empty result if parsing fails or no video results found
            Ok(SearchVideoResult {
                items: vec![],
                page,
                page_size: 20,
                num_results: 0,
            })
        }
        Err(ApiError::NetworkUnavailable) => Err(SerializableError {
            code: "NETWORK_ERROR".to_string(),
            message: "Network unavailable".to_string(),
        }),
        Err(err) => Err(SerializableError {
            code: "API_ERROR".to_string(),
            message: err.to_string(),
        }),
    }
}
