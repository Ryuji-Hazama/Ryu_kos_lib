DECLARE GLOBAL FUNCTION gentleThrottleUp {
	PARAMETER current_throttle, target_throttle.
	LOCK THROTTLE TO current_throttle.

	FROM { SET t TO current_throttle. } UNTIL t >= target_throttle STEP { SET t TO t + 0.05. } DO {
		SET current_throttle TO t.
		WAIT 0.05.
	}

	SET current_throttle TO target_throttle.
	RETURN target_throttle.
}

DECLARE GLOBAL FUNCTION gentleThrottleDown {
	PARAMETER current_throttle, target_throttle.
	LOCK THROTTLE TO current_throttle.

	FROM { SET t TO current_throttle. } UNTIL t <= target_throttle STEP { SET t TO t - 0.05. } DO {
		SET current_throttle TO t.
		WAIT 0.05.
	}

	SET current_throttle TO target_throttle.
	RETURN target_throttle.
}

DECLARE GLOBAL FUNCTION getCurrentPitch {
	RETURN 90 - VANG(SHIP:FACING:VECTOR, SHIP:UP:VECTOR).
}
