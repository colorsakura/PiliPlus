use std::time::Duration;

#[derive(Clone, Debug)]
pub struct RetryPolicy {
    pub max_attempts: u32,
    pub initial_delay: Duration,
    pub max_delay: Duration,
    pub backoff_multiplier: f64,
}

impl Default for RetryPolicy {
    fn default() -> Self {
        Self {
            max_attempts: 3,
            initial_delay: Duration::from_secs(1),
            max_delay: Duration::from_secs(30),
            backoff_multiplier: 2.0,
        }
    }
}

impl RetryPolicy {
    /// Calculate the delay for a given attempt number (1-indexed)
    /// Uses exponential backoff: initial_delay * (backoff_multiplier ^ (attempt - 1))
    /// Capped at max_delay
    pub fn delay_for_attempt(&self, attempt: u32) -> Duration {
        if attempt == 0 || attempt > self.max_attempts {
            return Duration::ZERO;
        }

        // Calculate exponential backoff
        let delay_ms = self.initial_delay.as_millis() as f64
            * self.backoff_multiplier.powi(attempt as i32 - 1);

        // Cap at max_delay
        let max_delay_ms = self.max_delay.as_millis() as f64;
        let capped_delay_ms = delay_ms.min(max_delay_ms);

        Duration::from_millis(capped_delay_ms as u64)
    }

    /// Determine if we should retry based on the current attempt number
    pub fn should_retry(&self, attempt: u32) -> bool {
        attempt < self.max_attempts
    }
}
