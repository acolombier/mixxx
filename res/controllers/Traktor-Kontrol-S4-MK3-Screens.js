/// Copyright (C) 2023 A. Colombier <mixxx@acolombier.dev>
///
/// This mapping is free software; you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation; either version 2 of the License, or
/// (at your option) any later version. The full text of the GNU
/// General Public License, version 2 can be found below. The licenses
/// of software libraries distributed together with Mixxx can be found
/// below as well.
///
/// In addition to the terms of the GNU General Public License, the following
/// license terms apply:
///

class S4MK3Screens {
    constructor() {

    }
    
    init() {
        const runtimeData = engine.getRuntimeData() || {};
        if (!runtimeData.group) {
            Object.assign(runtimeData, {
                group: ["[Channel1]", "[Channel2]"],
            });
        }
        engine.setRuntimeData(runtimeData);
    }
    shutdown() {
        const data = new Array(320*240*2 + 20).fill(0);
        data[0] = 0x84;
        data[3] = 0x21;
        data[12] = 0x1;
        data[13] = 0x40;
        data[15] = 0xf0;
        data[320*240*2 + 16] = 0x40;
        for (var i = 0; i < 320 * 240; i ++) {
            data[16 + 2 * i] = 0;
            data[16 + 2 * i + 1] = 0;
        }
        data[2] = 0;
        console.log("Turning off screen #0");
        controller.send(data);
        console.log("Screen #0 turned off");
        data[2] = 1;
        console.log("Turning off screen #1");
        controller.send(data);
        console.log("Screen #1 turned off");
    }
}

/* eslint no-unused-vars: "off", no-var: "off" */
var TraktorS4MK3Screens = new S4MK3Screens();
