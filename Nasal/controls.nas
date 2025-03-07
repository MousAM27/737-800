##

var TRIM_RATE = 0.01;

var elevatorTrim = func {
	var ap_a_on = getprop("/autopilot/internal/CMDA");
	var ap_b_on = getprop("/autopilot/internal/CMDB");
	var stab_pos = num( getprop("/fdm/jsbsim/fcs/stabilizer-pos-unit") );
	var flaps_pos = num( getprop("/fdm/jsbsim/fcs/flap-pos-norm") );

	if (ap_a_on or ap_b_on) {
		autopilot737.ap_disengage();
	}

	setprop("fdm/jsbsim/fcs/stabilizer/stab-target", arg[0] * -17);

	if (stab_pos > 12.5 and arg[0]*-1 == 1) setprop( "fdm/jsbsim/fcs/stabilizer/stab-target", stab_pos );
	if (stab_pos < 2.5 and arg[0]*-1 == -1 and flaps_pos == 0) setprop( "fdm/jsbsim/fcs/stabilizer/stab-target", stab_pos );
	if (stab_pos < 0.25 and arg[0]*-1 == -1 and flaps_pos > 0) setprop( "fdm/jsbsim/fcs/stabilizer/stab-target", stab_pos );

	
	settimer( elev_trim_stop, 0.1 );
}

var elev_trim_stop = func {
  var stab_pos = num( getprop("/fdm/jsbsim/fcs/stabilizer-pos-unit") );
  setprop("fdm/jsbsim/fcs/stabilizer/stab-target", stab_pos);
}

var trim_handler = func{
  var old_trim = num( getprop("b737/controls/trim/stabilizer-old") );
  if ( old_trim == nil ) old_trim = 0.0;
  var new_trim = num( getprop("/controls/flight/elevator-trim") );
  if ( new_trim == nil ) new_trim = 0.0;
  var delta = new_trim - old_trim;
  setprop( "b737/controls/trim/stabilizer-old", new_trim );
  if( delta > 0.0 ) elevatorTrim(1);
  if( delta < 0.0 ) elevatorTrim(-1);
}
setlistener( "/controls/flight/elevator-trim", trim_handler );

var elev_trim_rate = func {
	var ap_a_on = getprop("/autopilot/internal/CMDA");
	var ap_b_on = getprop("/autopilot/internal/CMDB");
	var flaps_pos = num( getprop("/fdm/jsbsim/fcs/flap-pos-norm") );

	var trim_speed = 0.6;                                                    #Fastest with flaps extended and manual control
	if (flaps_pos == 0 and !ap_a_on and !ap_b_on) trim_speed = 0.2; #With flaps retracted and AP off
	if (flaps_pos > 0 and (ap_a_on or ap_b_on)) trim_speed = 0.18;   #With flaps extended and AP on
	if (flaps_pos == 0 and (ap_a_on or ap_b_on)) trim_speed = 0.09;  #With flaps retracted and AP on
	setprop("fdm/jsbsim/fcs/stabilizer/trim-rate", trim_speed);
}
setlistener( "/autopilot/internal/CMDA", elev_trim_rate, 0, 0);
setlistener( "/autopilot/internal/CMDB", elev_trim_rate, 0, 0);
setlistener( "/fdm/jsbsim/fcs/flap-pos-norm", elev_trim_rate, 0, 0);
elev_trim_rate();

var stop_stab_move = func {
	var ap_a_on = getprop("/autopilot/internal/CMDA");
	var ap_b_on = getprop("/autopilot/internal/CMDB");
	if (!ap_a_on and !ap_b_on) setprop( "fdm/jsbsim/fcs/stabilizer/stab-target", getprop("/fdm/jsbsim/fcs/stabilizer-pos-unit") );
}
setlistener( "/autopilot/internal/CMDA", stop_stab_move, 0, 0);
setlistener( "/autopilot/internal/CMDB", stop_stab_move, 0, 0);
############################################
#### SPOILERS
############################################
var spoilers_control = func {
  var lever_pos = num( getprop("b737/controls/flight/spoilers-lever-pos") );

  if (lever_pos == 0) {
    setprop( "/controls/flight/speedbrake", 0.00 );
    if (getprop("/sim/messages/copilot") == "Spoilers DOWN!") { } else {
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers DOWN!");}
    setprop("b737/sound/spoiler-auto", 0);
  }
  if (lever_pos == 1) {
    setprop( "/controls/flight/speedbrake", 0.00 );
    if (getprop("/sim/messages/copilot") == "Spoilers ARMED!") { } else {
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers ARMED!");}
  }
  if (lever_pos == 2) setprop( "/controls/flight/speedbrake", 0.1625 );
  if (lever_pos == 3) {
    setprop( "/controls/flight/speedbrake", 0.325 );
    setprop( "/controls/flight/spoilers", 0 );
  }
  if (lever_pos == 4) {
    setprop( "/controls/flight/speedbrake", 0.4875 );

    var wow_right = getprop("/gear/gear[2]/wow");
    if (wow_right) setprop( "/controls/flight/spoilers", 1 );
    if (!wow_right) setprop( "/controls/flight/spoilers", 0 );

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;
    settimer(spoilers_control, time);
  }
  if (lever_pos == 5) {
    setprop( "/controls/flight/speedbrake", 0.65 );

    var wow_right = getprop("/gear/gear[2]/wow");
    if (wow_right) setprop( "/controls/flight/spoilers", 1 );
    if (!wow_right) setprop( "/controls/flight/spoilers", 0 );

    if (getprop("/sim/messages/copilot") == "Spoilers at FLIGHT DETENT!") { } else {
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers at FLIGHT DETENT!");}

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;
    settimer(spoilers_control, time);
  }
  if (lever_pos == 6) {
    setprop( "/controls/flight/speedbrake", 1.00 );

    var wow_right = getprop("/gear/gear[2]/wow");
    if (wow_right) setprop( "/controls/flight/spoilers", 1 );
    if (!wow_right) setprop( "/controls/flight/spoilers", 0 );

    if (getprop("/sim/messages/copilot") == "Spoilers UP!") { } else {
    if (getprop("sim/co-pilot")) setprop ("/sim/messages/copilot", "Spoilers UP!");}

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;
    settimer(spoilers_control, time);
  }
}

setlistener( "/b737/controls/flight/spoilers-lever-pos", spoilers_control, 0, 0 );

var landing_check = func{
	var air_ground = getprop("/b737/sensors/air-ground");
	var spin_up = getprop("/b737/sensors/main-gear-spin");
	var was_ia = getprop("/b737/sensors/was-in-air");
	var landing = getprop("/b737/sensors/landing");
	var lever_pos = num( getprop("b737/controls/flight/spoilers-lever-pos") );
	var throttle_1 = getprop("/autopilot/internal/servo-throttle[0]");
	var throttle_2 = getprop("/autopilot/internal/servo-throttle[1]");
	var ab_pos = getprop("/controls/gear/autobrakes");
	var ab_used = getprop("/fdm/jsbsim/fcs/autobrake/autobrake-used");

	if ((air_ground == "ground" or spin_up) and was_ia and throttle_1 < 0.05 and throttle_2 < 0.05 and !landing) { #normal landing
		if (lever_pos == 1) {
			setprop("b737/controls/flight/spoilers-lever-pos", 6);
			setprop("b737/sound/spoiler-auto", 1);
		}
		if (ab_pos > 0 and !ab_used) autobrake_apply();
		setprop("/b737/sensors/landing-time", getprop("/fdm/jsbsim/sim-time-sec"));
		settimer(func {setprop("/autopilot/internal/SPD", 0);},2);
		setprop("/b737/sensors/landing", 1);
	} elsif (air_ground == "ground" and !was_ia and spin_up and getprop("/controls/engines/engine[0]/throttle") < 0.05 and getprop("/controls/engines/engine[1]/throttle") < 0.05 and ab_pos == -1) { #Rejected take-off
		var GROUNDSPEED = getprop("/velocities/uBody-fps") * 0.593;
		setprop("/autopilot/internal/SPD", 0);
		if (lever_pos == 0) {
			setprop("b737/controls/flight/spoilers-lever-pos", 6);
			setprop("b737/sound/spoiler-auto", 1);
		}

		if (!ab_used and GROUNDSPEED > 84) {
			autobrake_apply();
		}
	}

    var height = getprop("/position/altitude-agl-ft");
    var time = height / 70;
    if (time < 0.2 or time > 600) time = 0.2;

    settimer(landing_check, time);
}
landing_check();


var ab_reset = func{
	var ab_pos = getprop("/controls/gear/autobrakes");
	var ab_used = getprop("/fdm/jsbsim/fcs/autobrake/autobrake-used");
	var ab_start_time = getprop("/fdm/jsbsim/fcs/autobrake/start-time-sec");

	if (ab_pos == 0 and ab_used) {
		setprop("/fdm/jsbsim/fcs/autobrake/autobrake-used", 0);
		setprop("/fdm/jsbsim/fcs/autobrake/start-time-sec", 0);
	}

}
setlistener( "/controls/gear/autobrakes", ab_reset, 0, 0);

var autobrake_apply = func {
	var ab_pos = getprop("/controls/gear/autobrakes");
	var ab_used = getprop("/fdm/jsbsim/fcs/autobrake/autobrake-used");
	var ab_start_time = getprop("/fdm/jsbsim/fcs/autobrake/start-time-sec");

	if (!ab_used) setprop("/fdm/jsbsim/fcs/autobrake/autobrake-in-use", 1);
	if (!ab_used) setprop("/fdm/jsbsim/fcs/autobrake/autobrake-used", 1);
	if (ab_start_time == 0 ) setprop("/fdm/jsbsim/fcs/autobrake/start-time-sec", getprop("/fdm/jsbsim/sim-time-sec"));

	if (ab_pos == 1) setprop("/fdm/jsbsim/fcs/autobrake/target-decel-fps_sec2", 4);
	if (ab_pos == 2) setprop("/fdm/jsbsim/fcs/autobrake/target-decel-fps_sec2", 5);
	if (ab_pos == 3) setprop("/fdm/jsbsim/fcs/autobrake/target-decel-fps_sec2", 7.2);
	if (ab_pos == 4) setprop("/fdm/jsbsim/fcs/autobrake/target-decel-fps_sec2",14);
	if (ab_pos == -1) setprop("/fdm/jsbsim/fcs/autobrake/target-decel-fps_sec2",25);
}

var left_brake = func {
	var ab_in_use = getprop("/fdm/jsbsim/fcs/autobrake/autobrake-in-use");
	var left_brake_cmd = getprop("/controls/gear/brake-left");
	var parking_brake_cmd = getprop("/controls/gear/brake-parking");

	if (ab_in_use) setprop("/fdm/jsbsim/fcs/autobrake/autobrake-in-use", 0);
	if (!parking_brake_cmd) {
		setprop("/fdm/jsbsim/fcs/brake-left-cmd", left_brake_cmd);
	} else {
		setprop("/fdm/jsbsim/fcs/brake-left-cmd", parking_brake_cmd);
	}
}
setlistener( "/controls/gear/brake-left", left_brake, 0, 0);

var right_brake = func {
	var ab_in_use = getprop("/fdm/jsbsim/fcs/autobrake/autobrake-in-use");
	var right_brake_cmd = getprop("/controls/gear/brake-right");
	var parking_brake_cmd = getprop("/controls/gear/brake-parking");

	if (ab_in_use) setprop("/fdm/jsbsim/fcs/autobrake/autobrake-in-use", 0);
	if (!parking_brake_cmd) {
		setprop("/fdm/jsbsim/fcs/brake-right-cmd", right_brake_cmd);
	} else {
		setprop("/fdm/jsbsim/fcs/brake-right-cmd", parking_brake_cmd);
	}
}
setlistener( "/controls/gear/brake-right", right_brake, 0, 0);

var parking_brake = func {
	var parking_brake_cmd = getprop("/controls/gear/brake-parking");

	setprop("/fdm/jsbsim/fcs/brake-right-cmd", parking_brake_cmd);
	setprop("/fdm/jsbsim/fcs/brake-left-cmd", parking_brake_cmd);
}
setlistener( "/controls/gear/brake-parking", parking_brake, 0, 0);

var parking_brake_set = func {
	setprop("/controls/gear/brake-parking", 1);
	setprop("/sim/menubar/visibility", "true");
}
settimer (parking_brake_set, 2);
