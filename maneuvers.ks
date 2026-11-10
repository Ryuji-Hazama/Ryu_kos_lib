DECLARE GLOBAL FUNCTION gentleThrottleUp {
	PARAMETER current_throttle, max_throttle.
	LOCK THROTTLE TO current_throttle.

	FROM { SET t TO current_throttle. } UNTIL t >= max_throttle STEP { SET t TO t + 0.05. } DO {
		SET current_throttle TO t.
		WAIT 0.05.
	}

	SET current_throttle TO max_throttle.
	RETURN max_throttle.
}

DECLARE GLOBAL FUNCTION gentleThrottleDown {
	PARAMETER current_throttle, min_throttle.
	LOCK THROTTLE TO current_throttle.

	FROM { SET t TO current_throttle. } UNTIL t <= min_throttle STEP { SET t TO t - 0.05. } DO {
		SET current_throttle TO t.
		WAIT 0.05.
	}

	SET current_throttle TO min_throttle.
	RETURN min_throttle.
}

DECLARE GLOBAL FUNCTION getCurrentPitch {
	RETURN 90 - VANG(SHIP:FACING:VECTOR, SHIP:UP:VECTOR).
}

DECLARE GLOBAL FUNCTION getCurrentTwr {
	PARAMETER current_throttle.
	LOCAL current_thrust IS SHIP:AVAILABLETHRUST * current_throttle.
	LOCAL radius IS SHIP:ALTITUDE + SHIP:BODY:RADIUS.
	LOCAL gee IS SHIP:BODY:MU / (radius * radius).
	RETURN current_thrust / (SHIP:MASS * gee).
}

DECLARE GLOBAL FUNCTION getApAdjustAngle {
	PARAMETER target_apoapsis.
	PARAMETER previous_apoapsis.
	SET current_apoapsis TO SHIP:ORBIT:APOAPSIS.
	SET diff TO current_apoapsis - previous_apoapsis.
	SET over_shoot TO (target_apoapsis - current_apoapsis) / 100.

	IF over_shoot <= -0.1 {
		IF diff > 80 {
			RETURN over_shoot.
		}
		ELSE IF diff > 30 {
			RETURN over_shoot * 0.5.
		}
		ELSE IF diff > -10 {
			RETURN over_shoot * 0.3.
		}
		ELSE IF diff < -50 {
			RETURN over_shoot * -0.5.
		}
		RETURN 0.
	}
	ELSE IF over_shoot >= 0.1 {
		IF diff < -80 {
			RETURN over_shoot.
		}
		ELSE IF diff < -35 {
			RETURN over_shoot * 0.5.
		}
		ELSE IF diff < 10 {
			RETURN over_shoot * 0.3.
		}
		ELSE IF diff > 50 {
			RETURN over_shoot * -0.5.
		}
		RETURN 0.
	}
	RETURN 0.
}