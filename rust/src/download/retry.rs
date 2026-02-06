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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_policy() {
        let policy = RetryPolicy::default();
        assert_eq!(policy.max_attempts, 3);
        assert_eq!(policy.initial_delay, Duration::from_secs(1));
        assert_eq!(policy.max_delay, Duration::from_secs(30));
        assert_eq!(policy.backoff_multiplier, 2.0);
    }

    #[test]
    fn test_delay_first_attempt() {
        let policy = RetryPolicy::default();
        let delay = policy.delay_for_attempt(1);
        assert_eq!(delay, Duration::from_secs(1));
    }

    #[test]
    fn test_delay_second_attempt() {
        let policy = RetryPolicy::default();
        let delay = policy.delay_for_attempt(2);
        assert_eq!(delay, Duration::from_secs(2));
    }

    #[test]
    fn test_delay_third_attempt() {
        let policy = RetryPolicy::default();
        let delay = policy.delay_for_attempt(3);
        assert_eq!(delay, Duration::from_secs(4));
    }

    #[test]
    fn test_delay_exponential_growth() {
        let policy = RetryPolicy {
            max_attempts: 5,
            initial_delay: Duration::from_secs(1),
            max_delay: Duration::from_secs(30),
            backoff_multiplier: 2.0,
        };
        assert_eq!(policy.delay_for_attempt(1), Duration::from_secs(1));
        assert_eq!(policy.delay_for_attempt(2), Duration::from_secs(2));
        assert_eq!(policy.delay_for_attempt(3), Duration::from_secs(4));
        assert_eq!(policy.delay_for_attempt(4), Duration::from_secs(8));
    }

    #[test]
    fn test_delay_capped_at_max() {
        let policy = RetryPolicy {
            max_attempts: 10,
            initial_delay: Duration::from_secs(1),
            max_delay: Duration::from_secs(5),
            backoff_multiplier: 2.0,
        };

        // Should grow exponentially but cap at 5 seconds
        assert_eq!(policy.delay_for_attempt(1), Duration::from_secs(1));
        assert_eq!(policy.delay_for_attempt(2), Duration::from_secs(2));
        assert_eq!(policy.delay_for_attempt(3), Duration::from_secs(4));
        assert_eq!(policy.delay_for_attempt(4), Duration::from_secs(5)); // capped
        assert_eq!(policy.delay_for_attempt(5), Duration::from_secs(5)); // capped
        assert_eq!(policy.delay_for_attempt(10), Duration::from_secs(5)); // capped
    }

    #[test]
    fn test_delay_zero_for_invalid_attempts() {
        let policy = RetryPolicy::default();
        assert_eq!(policy.delay_for_attempt(0), Duration::ZERO);
        assert_eq!(policy.delay_for_attempt(100), Duration::ZERO);
    }

    #[test]
    fn test_should_retry() {
        let policy = RetryPolicy::default();
        assert!(policy.should_retry(0));  // First attempt
        assert!(policy.should_retry(1));  // After 1st failure
        assert!(policy.should_retry(2));  // After 2nd failure
        assert!(!policy.should_retry(3)); // After 3rd failure (max_attempts=3)
        assert!(!policy.should_retry(4)); // Beyond max
    }

    #[test]
    fn test_custom_policy() {
        let policy = RetryPolicy {
            max_attempts: 5,
            initial_delay: Duration::from_millis(500),
            max_delay: Duration::from_secs(10),
            backoff_multiplier: 3.0,
        };

        assert_eq!(policy.max_attempts, 5);
        assert_eq!(policy.delay_for_attempt(1), Duration::from_millis(500));
        assert_eq!(policy.delay_for_attempt(2), Duration::from_millis(1500)); // 500 * 3
        assert_eq!(policy.delay_for_attempt(3), Duration::from_millis(4500)); // 500 * 3^2
    }
}
