/// Copyright (C) 2023 Be <be@mixxx.org> and A. Colombier <mixxx@acolombier.dev>
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
/// By using this mapping, you confirm that you are not Bob Ham, you are in no
/// way affiliated to Bob Ham, you are not downloading this code on behalf of
/// Bob Ham or an associate of Bob Ham. To the best of your knowledge, information
/// and belief this mapping will not make its way into the hands of Bob Ham.

const LedColors = {
    off: 0,
    red: 4,
    carrot: 8,
    orange: 12,
    honey: 16,
    yellow: 20,
    lime: 24,
    green: 28,
    aqua: 32,
    celeste: 36,
    sky: 40,
    blue: 44,
    purple: 48,
    fuscia: 52,
    magenta: 56,
    azalea: 60,
    salmon: 64,
    white: 68,
};

// A full list can be found here: https://manual.mixxx.org/2.4/en/chapters/appendix/mixxx_controls.html#control-[Library]-sort_column
const LibraryColumns = {
    Artist: 1,
    Title: 2,
    Album: 3,
    Albumartist: 4,
    Year: 5,
    Genre: 6,
    Composer: 7,
    Grouping: 8,
    Tracknumber: 9,
    Filetype: 10,
    NativeLocation: 11,
    Comment: 12,
    Duration: 13,
    Bitrate: 14,
    BPM: 15,
    ReplayGain: 16,
    DatetimeAdded: 17,
    TimesPlayed: 18,
    Rating: 19,
};

const KeyboardColors = [
    LedColors.green,
    LedColors.off,
    LedColors.white,
    LedColors.off,
    LedColors.white,
    LedColors.white,
    LedColors.off,
    LedColors.white,
    LedColors.off,
    LedColors.white,
    LedColors.off,
    LedColors.white,
];

/*
 * USER CONFIGURABLE SETTINGS
 * Adjust these to your liking
 */

const DeckColors = [
    LedColors.red,
    LedColors.blue,
    LedColors.yellow,
    LedColors.purple,
];

const LibrarySortableColumns = [
    LibraryColumns.Artist,
    LibraryColumns.Title,
    LibraryColumns.BPM,
    LibraryColumns.Key,
    LibraryColumns.DatetimeAdded,
];

const LOOP_WHEEL_MOVE_FACTOR = 50; // LOOP_WHEEL_MOVE_FACTOR
const LOOP_ENCODER_MOVE_FACTOR = 500; // LOOP_ENCODER_MOVE_FACTOR
const LOOP_ENCODER_SHIFTMOVE_FACTOR = 2500; // LOOP_ENCODER_SHIFTMOVE_FACTOR

const TempoFaderSoftTakeoverColorLow = LedColors.white;
const TempoFaderSoftTakeoverColorHigh = LedColors.green;

// Define whether or not to keep LED that have only one color (reverse, flux, play, shift) dimmed if they are inactive.
// 'true' will keep them dimmed, 'false' will turn them off. Default: true
const KeepLEDWithOneColorDimedWhenInactive = true;

// Keep both deck select buttons backlit and do not fully turn off the inactive deck button.
// 'true' will keep the unseclected deck dimmed, 'false' to fully turn it off. Default: true
const KeepDeckSelectDimmed = true;

// Define whether the keylock is mapped when doing "shift+master" (on press) or "shift+sync" (on release since long push copies the key)".
// 'true' will use "sync+master", 'false' will use "shift+sync". Default: false
const UseKeylockOnMaster = false;

// Define whether the grid button would blink when the playback is going over a detcted beat. Can help to adjust beat grid.
// Default: false
const GridButtonBlinkOverBeat = false;

// Define how many wheel moves are sampled to compute the speed. The more you have, the more the speed is accurate, but the
// less responsive it gets in Mixxx. Default: 5
const WheelSpeedSample = 5;

// Make the sampler tab a beatlooproll tab instead
// Default: false
const UseBeatloopRoolInsteadOfSampler = true;

// Define the speed of the jogwheel. This will impact the speed of the LED playback indicator, the sratch, and the speed of
// the motor if enable. Recommended value are 33 + 1/3 or 45.
// Default: 33 + 1/3
const BaseRevolutionsPerMinute = 33 + 1/3;

// Define whether or not to use motors.
// This is a BETA feature! Please use at your own risk. Setting this off means that below settings are inactive
// Default: false
const UseMotors = true;

// Define how many wheel moves are sampled to compute the speed when using the motor. This is helpful to mitigate delay that
// occurs in communication as well as Mixxx limitation to 20ms latency.
// The more you have, the more the speed is accurate.
// less responsive it gets in Mixxx. Default: 40
const TurnTableSpeedSample = 15;

// Define how much the wheel will resist. It is a similar setting that the Grid+Wheel in Tracktor
// Value must defined between 0 to 1. 0 is very tight, 1 is very loose.
// Default: 0.5
const TightnessFactor = 0.5;

// Define how much force can the motor use. This defines how much the wheel will "fight" you when you block it in TT mode
// This will also im
const MaxWheelForce = 25000;  // Traktor seems to cap the max value at 60000, which just sounds insane



// The LEDs only support 16 base colors. Adding 1 in addition to
// the normal 2 for Button.prototype.brightnessOn changes the color
// slightly, so use that get 25 different colors to include the Filter
// button as a 5th effect chain preset selector.
const QuickEffectPresetColors = [
    LedColors.red,
    LedColors.green,
    LedColors.blue,
    LedColors.yellow,
    LedColors.orange,
    LedColors.purple,
    LedColors.white,

    LedColors.magenta,
    LedColors.azalea,
    LedColors.salmon,
    LedColors.red + 1,

    LedColors.sky,
    LedColors.celeste,
    LedColors.fuscia,
    LedColors.blue + 1,

    LedColors.carrot,
    LedColors.honey,
    LedColors.yellow + 1,

    LedColors.lime,
    LedColors.aqua,
    LedColors.purple + 1,

    LedColors.magenta + 1,
    LedColors.azalea + 1,
    LedColors.salmon + 1,
    LedColors.fuscia + 1,
];

// assign samplers to the crossfader on startup
const SamplerCrossfaderAssign = true;

const MotorWindUpMilliseconds = 1200;
const MotorWindDownMilliseconds = 900;

/*
 * HID packet parsing library
 */
class HIDInputPacket {
    constructor(reportId) {
        this.reportId = reportId;
        this.fields = [];
    }

    registerCallback(callback, byteOffset, bitOffset, bitLength, defaultOldData) {
        if (typeof callback !== "function") {
            throw Error("callback must be a function");
        }

        if (byteOffset === undefined || typeof byteOffset !== "number" || !Number.isInteger(byteOffset)) {
            throw Error("byteOffset must be 0 or a positive integer");
        }

        if (bitOffset === undefined) {
            bitOffset = 0;
        }
        if (typeof bitOffset !== "number" || bitOffset < 0 || !Number.isInteger(bitOffset)) {
            throw Error("bitOffset must be 0 or a positive integer");
        }

        if (bitLength === undefined) {
            bitLength = 1;
        }
        if (typeof bitLength !== "number" || bitLength < 1 || !Number.isInteger(bitOffset) || bitLength > 32) {
            throw Error("bitLength must be an integer between 1 and 32");
        }

        const field = {
            callback: callback,
            byteOffset: byteOffset,
            bitOffset: bitOffset,
            bitLength: bitLength,
            oldData: defaultOldData
        };
        this.fields.push(field);

        return {
            disconnect: () => {
                this.fields = this.fields.filter((element) => {
                    return element !== field;
                });
            }
        };
    }

    handleInput(byteArray, bufferHasNoReportID) {
        const offset = bufferHasNoReportID ? -1 : 0;
        const view = new DataView(byteArray);
        if (!bufferHasNoReportID && view.getUint8(0) !== this.reportId) {
            return;
        }

        for (const field of this.fields) {
            const numBytes = Math.ceil(field.bitLength / 8);
            let data;

            // Little endianness is specified by the HID standard.
            // The HID standard allows signed integers as well, but I am not aware
            // of any HID DJ controllers which use signed integers.
            if (numBytes === 1) {
                data = view.getUint8(field.byteOffset + offset);
            } else if (numBytes === 2) {
                data = view.getUint16(field.byteOffset + offset, true);
            } else if (numBytes === 3) {
                data = view.getUint32(field.byteOffset + offset, true) >>> 8;
            } else if (numBytes === 4) {
                data = view.getUint32(field.byteOffset + offset, true);
            } else {
                throw Error("field bitLength must be between 1 and 32");
            }

            // The >>> 0 is required for 32 bit unsigned ints to not magically turn negative
            // because all Numbers are really 32 bit signed floats. Because JavaScript.
            data = ((data >> field.bitOffset) & (2 ** field.bitLength - 1)) >>> 0;

            if (field.oldData !== data) {
                field.callback(data);
                field.oldData = data;
            }
        }
    }
}

class HIDOutputPacket {
    constructor(reportId, length) {
        this.reportId = reportId;
        this.data = Array(length).fill(0);
    }
    send() {
        controller.send(this.data, null, this.reportId);
    }
}

/*
 * Components library
 */

class Component {
    constructor(options) {
        if (options) {
            Object.keys(options).forEach(function(key) {
                if (options[key] === undefined) { delete options[key]; }
            });
            Object.assign(this, options);
        }
        this.outConnections = [];
        if (typeof this.key === "string") {
            this.inKey = this.key;
            this.outKey = this.key;
        }
        if (this.unshift !== undefined && typeof this.unshift === "function") {
            this.unshift();
        }
        this.shifted = false;
        if (this.input !== undefined && typeof this.input === "function"
            && this.inPacket !== undefined && this.inPacket instanceof HIDInputPacket) {
            this.inConnect();
        }
        this.outConnect();
    }
    inConnect(callback) {
        if (this.inByte === undefined
            || this.inBit === undefined
            || this.inBitLength === undefined
            || this.inPacket === undefined) {
            return;
        }
        if (typeof callback === "function") {
            this.input = callback;
        }
        this.inConnection = this.inPacket.registerCallback(this.input.bind(this), this.inByte, this.inBit, this.inBitLength, this.oldDataDefault);
    }
    inDisconnect() {
        if (this.inConnection !== undefined) {
            this.inConnection.disconnect();
        }
    }
    send(value) {
        if (this.outPacket !== undefined && this.outByte !== undefined) {
            this.outPacket.data[this.outByte] = value;
            this.outPacket.send();
        }
    }
    output(value) {
        this.send(value);
    }
    outConnect() {
        if (this.outKey !== undefined && this.group !== undefined) {
            const connection = engine.makeConnection(this.group, this.outKey, this.output.bind(this));
            // This is useful for case where effect would have been fully disabled in Mixxx. This appears to be the case during unit tests.
            if (connection) {
                this.outConnections[0] = connection;
            } else {
                console.warn("Unable to connect '" + this.group + "." + this.outKey + "' to the controller output. The control appears to be unavailable.");
            }
        }
    }
    outDisconnect() {
        for (const connection of this.outConnections) {
            connection.disconnect();
        }
        this.outConnections = [];
    }
    outTrigger() {
        for (const connection of this.outConnections) {
            connection.trigger();
        }
    }
}
class ComponentContainer extends Component {
    constructor() {
        super();
    }
    *[Symbol.iterator]() {
        // can't use for...of here because it would create an infinite loop
        for (const property in this) {
            if (Object.prototype.hasOwnProperty.call(this, property)) {
                const obj = this[property];
                if (obj instanceof Component) {
                    yield obj;
                } else if (Array.isArray(obj)) {
                    for (const objectInArray of obj) {
                        if (objectInArray instanceof Component) {
                            yield objectInArray;
                        }
                    }
                }
            }
        }
    }
    reconnectComponents(callback) {
        for (const component of this) {
            if (component.outDisconnect !== undefined && typeof component.outDisconnect === "function") {
                component.outDisconnect();
            }
            if (callback !== undefined && typeof callback === "function") {
                callback.call(this, component);
            }
            if (component.outConnect !== undefined && typeof component.outConnect === "function") {
                component.outConnect();
            }
            component.outTrigger();
            if (component.unshift !== undefined && typeof component.unshift === "function") {
                component.unshift();
            }
        }
    }
    unshift() {
        for (const component of this) {
            if (component.unshift !== undefined && typeof component.unshift === "function") {
                component.unshift();
            }
            component.shifted = false;
        }
    }
    shift() {
        for (const component of this) {
            if (component.shift !== undefined && typeof component.shift === "function") {
                component.shift();
            }
            component.shifted = true;
        }
    }
}

/* eslint no-redeclare: "off" */
class Deck extends ComponentContainer {
    constructor(decks, colors, deckId) {
        super();
        this.deckId = deckId;
        if (typeof decks === "number") {
            this.group = Deck.groupForNumber(decks);
        } else if (Array.isArray(decks)) {
            this.decks = decks;
            this.currentDeckNumber = decks[0];
            this.group = Deck.groupForNumber(decks[0]);
        }
        if (colors !== undefined && Array.isArray(colors)) {
            this.groupsToColors = {};
            let index = 0;
            for (const deck of this.decks) {
                this.groupsToColors[Deck.groupForNumber(deck)] = colors[index];
                index++;
            }
            this.color = colors[0];
        }
        this.secondDeckModes = null;
    }
    toggleDeck() {
        if (this.decks === undefined) {
            throw Error("toggleDeck can only be used with Decks constructed with an Array of deck numbers, for example [1, 3]");
        }

        const currentDeckIndex = this.decks.indexOf(this.currentDeckNumber);
        let newDeckIndex = currentDeckIndex + 1;
        if (currentDeckIndex >= this.decks.length) {
            newDeckIndex = 0;
        }

        this.switchDeck(Deck.groupForNumber(this.decks[newDeckIndex]));
    }
    switchDeck(newGroup) {
        const currentModes = {
            wheelMode: this.wheelMode,
            moveMode: this.moveMode,
        };

        engine.setValue(this.group, "scratch2_enable", false);
        this.group = newGroup;

        this.color = this.groupsToColors[newGroup];

        if (this.secondDeckModes !== null) {
            this.wheelMode = this.secondDeckModes.wheelMode;
            this.moveMode = this.secondDeckModes.moveMode;

            if (this.wheelMode === wheelModes.motor) {
                engine.beginTimer(MotorWindUpMilliseconds, function() {
                    engine.setValue(newGroup, "scratch2_enable", true);
                }, true);
            }
        }

        if (currentModes.wheelMode === wheelModes.motor) {
            this.wheelTouch.touched = true;
            engine.beginTimer(MotorWindDownMilliseconds, () => {
                this.wheelTouch.touched = false;
            }, true);
        }
        this.reconnectComponents(function(component) {
            if (component.group === undefined
                || component.group.search(script.channelRegEx) !== -1) {
                component.group = newGroup;
            } else if (component.group.search(script.eqRegEx) !== -1) {
                component.group = "[EqualizerRack1_" + newGroup + "_Effect1]";
            } else if (component.group.search(script.quickEffectRegEx) !== -1) {
                component.group = "[QuickEffectRack1_" + newGroup + "]";
            }

            component.color = this.groupsToColors[newGroup];
        });
        this.secondDeckModes = currentModes;
    }
    static groupForNumber(deckNumber) {
        return "[Channel" + deckNumber + "]";
    }
}

class Button extends Component {
    constructor(options) {
        options.oldDataDefault = 0;

        super(options);

        if (this.input === undefined) {
            this.input = this.defaultInput;
            if (typeof this.input === "function"
                && this.inPacket !== undefined && this.inPacket instanceof HIDInputPacket) {
                this.inConnect();
            }
        }

        if (this.longPressTimeOut === undefined) {
            this.longPressTimeOut = 225; // milliseconds
        }
        if (this.indicatorInterval === undefined) {
            this.indicatorInterval = 350; // milliseconds
        }
        this.longPressTimer = 0;
        this.indicatorTimer = 0;
        this.indicatorState = false;
        this.isLongPress = false;
        if (this.inBitLength === undefined) {
            this.inBitLength = 1;
        }
    }
    setKey(key) {
        this.inKey = key;
        if (key === this.outKey) {
            return;
        }
        this.outDisconnect();
        this.outKey = key;
        this.outConnect();
        this.outTrigger();
    }
    setGroup(group) {
        if (group === this.group) {
            return;
        }
        this.outDisconnect();
        this.group = group;
        this.outConnect();
        this.outTrigger();
    }
    output(value) {
        if (this.indicatorTimer !== 0) {
            return;
        }
        const brightness = (value > 0) ? this.brightnessOn : this.brightnessOff;
        this.send((this.color || LedColors.white) + brightness);
    }
    indicatorCallback() {
        this.indicatorState = !this.indicatorState;
        this.send((this.indicatorColor || this.color || LedColors.white) + (this.indicatorState ? this.brightnessOn : this.brightnessOff));
    }
    indicator(on) {
        if (on && this.indicatorTimer === 0) {
            this.outDisconnect();
            this.indicatorTimer = engine.beginTimer(this.indicatorInterval, this.indicatorCallback.bind(this));
        } else if (!on && this.indicatorTimer !== 0) {
            engine.stopTimer(this.indicatorTimer);
            this.indicatorTimer = 0;
            this.indicatorState = false;
            this.outConnect();
            this.outTrigger();
        }
    }
    defaultInput(pressed) {
        if (pressed) {
            this.isLongPress = false;
            if (typeof this.onShortPress === "function") { this.onShortPress(); }
            if (typeof this.onLongPress === "function" || typeof this.onLongRelease === "function") {
                this.longPressTimer = engine.beginTimer(this.longPressTimeOut, () => {
                    this.isLongPress = true;
                    this.longPressTimer = 0;
                    if (typeof this.onLongPress !== "function") { return; }
                    this.onLongPress(this);
                }, true);
            }
        } else if (this.isLongPress) {
            if (typeof this.onLongRelease === "function") { this.onLongRelease(); }
        } else {
            if (this.longPressTimer !== 0) {
                engine.stopTimer(this.longPressTimer);
                this.longPressTimer = 0;
            }
            if (typeof this.onShortRelease === "function") { this.onShortRelease(); }
        }
    }
}

class PushButton extends Button {
    constructor(options) {
        super(options);
    }
    input(pressed) {
        engine.setValue(this.group, this.inKey, pressed);
    }
}

class ToggleButton extends Button {
    constructor(options) {
        super(options);
    }
    onShortPress() {
        script.toggleControl(this.group, this.inKey, true);
    }
}

class TriggerButton extends Button {
    constructor(options) {
        super(options);
    }
    onShortPress() {
        engine.setValue(this.group, this.inKey, true);
    }
    onShortRelease() {
        engine.setValue(this.group, this.inKey, false);
    }
}

class PowerWindowButton extends Button {
    constructor(options) {
        super(options);
        this.isLongPressed = false;
        this.longPressTimer = 0;
    }
    onShortPress() {
        script.toggleControl(this.group, this.inKey);
    }
    onLongRelease() {
        script.toggleControl(this.group, this.inKey);
    }
}

class PlayButton extends Button {
    constructor(options) {
        // Prevent accidental ejection/duplication accident
        options.longPressTimeOut = 800;
        super(options);
        this.inKey = "play";
        this.outKey = "play_indicator";
        this.outConnect();
    }
    onShortPress() {
        script.toggleControl(this.group, this.inKey, true);
    }
    onLongPress() {
        if (this.shifted) {
            engine.setValue(this.group, this.inKey, false);
            script.triggerControl(this.group, "eject");
        } else if (!engine.getValue(this.group, this.inKey)) {
            script.triggerControl(this.group, "CloneFromDeck");
        }
    }
}

class CueButton extends PushButton {
    constructor(options) {
        super(options);
        this.outKey = "cue_indicator";
        this.outConnect();
    }
    unshift() {
        this.inKey = "cue_default";
    }
    shift() {
        this.inKey = "start_stop";
    }
    input(pressed) {
        if (this.deck.moveMode === moveModes.keyboard && !this.deck.keyboardPlayMode) {
            this.deck.assignKeyboardPlayMode(this.group, this.inKey);
        } else if (this.deck.wheelMode === wheelModes.motor && engine.getValue(this.group, "play") && pressed) {
            engine.setValue(this.group, "cue_goto", pressed);
        } else {
            engine.setValue(this.group, this.inKey, pressed);
            if (this.deck.wheelMode === wheelModes.motor) {
                engine.setValue(this.group, "scratch2_enable", false);
                engine.beginTimer(MotorWindDownMilliseconds, function() {
                    engine.setValue(this.group, "scratch2_enable", true);
                }, true);
            }
        }
    }
}

class Encoder extends Component {
    constructor(options) {
        super(options);
        this.lastValue = null;
    }
    input(value) {
        const oldValue = this.lastValue;
        this.lastValue = value;

        if (oldValue === null || typeof this.onChange !== "function") {
            // This scenario happens at the controller initialisation. No real input to proceed
            return;
        }
        let isRight;
        if (oldValue === this.max && value === 0) {
            isRight = true;
        } else if (oldValue === 0 && value === this.max) {
            isRight = false;
        } else {
            isRight = value > oldValue;
        }
        this.onChange(isRight);
    }
}

class HotcueButton extends PushButton {
    constructor(options) {
        super(options);
        if (this.number === undefined || !Number.isInteger(this.number) || this.number < 1 || this.number > 32) {
            throw Error("HotcueButton must have a number property of an integer between 1 and 32");
        }
        this.outKey = "hotcue_" + this.number + "_enabled";
        this.colorKey = "hotcue_" + this.number + "_color";
        this.outConnect();
    }
    unshift() {
        this.inKey = "hotcue_" + this.number + "_activate";
    }
    shift() {
        this.inKey = "hotcue_" + this.number + "_clear";
    }
    input(pressed) {
        engine.setValue(this.group, "scratch2_enable", false);
        engine.setValue(this.group, this.inKey, pressed);
    }
    output(value) {
        if (value) {
            this.send(this.color + this.brightnessOn);
        } else {
            this.send(0);
        }
    }
    outConnect() {
        if (undefined !== this.group) {
            const connection0 = engine.makeConnection(this.group, this.outKey, this.output.bind(this));
            if (connection0) {
                this.outConnections[0] = connection0;
            } else {
                console.warn("Unable to connect '" + this.group + "." + this.outKey + "' to the controller output. The control appears to be unavailable.");
            }
            const connection1 = engine.makeConnection(this.group, this.colorKey, (colorCode) => {
                this.color = this.colorMap.getValueForNearestColor(colorCode);
                this.output(engine.getValue(this.group, this.outKey));
            });
            if (connection1) {
                this.outConnections[1] = connection1;
            } else {
                console.warn("Unable to connect '" + this.group + "." + this.colorKey + "' to the controller output. The control appears to be unavailable.");
            }
        }
    }
}

class KeyboardButton extends PushButton {
    constructor(options) {
        super(options);
        if (this.number === undefined || !Number.isInteger(this.number) || this.number < 1 || this.number > 8) {
            throw Error("KeyboardButton must have a number property of an integer between 1 and 8");
        }
        if (this.deck === undefined) {
            throw Error("KeyboardButton must have a deck attached to it");
        }
        this.outConnect();
    }
    unshift() {
        this.outTrigger();
    }
    shift() {
        this.outTrigger();
    }
    input(pressed) {
        const offset = this.deck.keyboardOffset - (this.shifted ? 8 : 0);
        if (this.number + offset < 1 || this.number + offset > 24) {
            return;
        }
        if (pressed) {
            engine.setValue(this.group, "key", this.number + offset);
        }
        if (this.deck.keyboardPlayMode !== null) {
            if (this.deck.keyboardPlayMode.activeKey && pressed) {
                engine.setValue(this.deck.keyboardPlayMode.group, "cue_goto", pressed);
            } else if (!this.deck.keyboardPlayMode.activeKey || this.deck.keyboardPlayMode.activeKey === this) {
                script.toggleControl(this.deck.keyboardPlayMode.group, this.deck.keyboardPlayMode.action, true);
            }
            if (!pressed && this.deck.keyboardPlayMode.activeKey === this) {
                this.deck.keyboardPlayMode.activeKey = undefined;
            } else if (pressed) {
                this.deck.keyboardPlayMode.activeKey = this;
            }
        }
    }
    output(value) {
        const offset = this.deck.keyboardOffset - (this.shifted ? 8 : 0);
        const colorIdx = (this.number - 1 + offset) % KeyboardColors.length;
        const color = KeyboardColors[colorIdx];
        if (this.number + offset < 1 || this.number + offset > 24) {
            this.send(0);
        } else {
            // if (color === LedColors.off && value){
            //     this.send(LedColors.white + this.brightnessOn);
            // } else {
            this.send(value ? LedColors.yellow : color);
            // }
        }
    }
    outConnect() {
        if (undefined !== this.group) {
            const connection = engine.makeConnection(this.group, "key", (key) => {
                const offset = this.deck.keyboardOffset - (this.shifted ? 8 : 0);
                this.output(key === this.number + offset);
            });
            if (connection) {
                this.outConnections[0] = connection;
            } else {
                console.warn("Unable to connect '" + this.group + ".key' to the controller output. The control appears to be unavailable.");
            }
        }
    }
}

const beatLoopRolls = [0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8];
class BeatLoopRollButton extends TriggerButton {
    constructor(options) {
        if (options.number === undefined || !Number.isInteger(options.number) || options.number < 0 || options.number > 7) {
            throw Error("BeatLoopRollButton must have a number property of an integer between 0 and 7");
        }
        options.key = "beatlooproll_"+beatLoopRolls[options.number]+"_activate";
        super(options);
        if (this.deck === undefined) {
            throw Error("BeatLoopRollButton must have a deck attached to it");
        }

        this.outConnect();
    }
    output(value) {
        this.send(LedColors.white + (value ? this.brightnessOn : this.brightnessOff));
    }
}

class SamplerButton extends Button {
    constructor(options) {
        super(options);
        if (this.number === undefined || !Number.isInteger(this.number) || this.number < 1 || this.number > 64) {
            throw Error("SamplerButton must have a number property of an integer between 1 and 64");
        }
        this.group = "[Sampler" + this.number + "]";
        this.outConnect();
    }
    onShortPress() {
        if (!this.shifted) {
            if (engine.getValue(this.group, "track_loaded") === 0) {
                engine.setValue(this.group, "LoadSelectedTrack", 1);
            } else {
                engine.setValue(this.group, "cue_gotoandplay", 1);
            }
        } else {
            if (engine.getValue(this.group, "play") === 1) {
                engine.setValue(this.group, "play", 0);
            } else {
                engine.setValue(this.group, "eject", 1);
            }
        }
    }
    onShortRelease() {
        if (this.shifted) {
            if (engine.getValue(this.group, "play") === 0) {
                engine.setValue(this.group, "eject", 0);
            }
        }
    }
    // This function is connected to multiple Controls, so don't use the value passed in as a parameter.
    output() {
        if (engine.getValue(this.group, "track_loaded")) {
            if (engine.getValue(this.group, "play")) {
                this.send(this.color + this.brightnessOn);
            } else {
                this.send(this.color + this.brightnessOff);
            }
        } else {
            this.send(0);
        }
    }
    outConnect() {
        if (undefined !== this.group) {
            const connection0 = engine.makeConnection(this.group, "play", this.output.bind(this));
            if (connection0) {
                this.outConnections[0] = connection0;
            } else {
                console.warn("Unable to connect '" + this.group + ".play' to the controller output. The control appears to be unavailable.");
            }
            const connection1 = engine.makeConnection(this.group, "track_loaded", this.output.bind(this));
            if (connection1) {
                this.outConnections[1] = connection1;
            } else {
                console.warn("Unable to connect '" + this.group + ".track_loaded' to the controller output. The control appears to be unavailable.");
            }
        }
    }
}

class IntroOutroButton extends PushButton {
    constructor(options) {
        super(options);
        if (this.cueBaseName === undefined || typeof this.cueBaseName !== "string") {
            throw Error("must specify cueBaseName as intro_start, intro_end, outro_start, or outro_end");
        }
        this.outKey = this.cueBaseName + "_enabled";
        this.outConnect();
    }
    unshift() {
        this.inKey = this.cueBaseName + "_activate";
    }
    shift() {
        this.inKey = this.cueBaseName + "_clear";
    }
    output(value) {
        if (value) {
            this.send(this.color + this.brightnessOn);
        } else {
            this.send(0);
        }
    }
}

class Pot extends Component {
    constructor(options) {
        super(options);
        this.hardwarePosition = null;
        this.shiftedHardwarePosition = null;
    }
    setGroupKey(group, key) {
        this.inKey = key;
        if (key === this.outKey && group === this.group) {
            return;
        }
        this.outDisconnect();
        this.group = group;
        this.outKey = key;
        this.outConnect();
    }
    input(value) {
        const receivingFirstValue = this.hardwarePosition === null;
        this.hardwarePosition = value / this.max;
        engine.setParameter(this.group, this.inKey, this.hardwarePosition);
        if (receivingFirstValue) {
            engine.softTakeover(this.group, this.inKey, true);
        }
    }
    outDisconnect() {
        if (this.hardwarePosition !== null) {
            engine.softTakeover(this.group, this.inKey, true);
        }
        engine.softTakeoverIgnoreNextValue(this.group, this.inKey);
        super.outDisconnect();
    }
}

class Mixer extends ComponentContainer {
    constructor(inPackets, outPackets) {
        super();

        this.outPacket = outPackets[128];

        this.mixerColumnDeck1 = new S4Mk3MixerColumn("[Channel1]", inPackets, outPackets[128],
            {
                saveGain: {inByte: 12, inBit: 0, outByte: 80},
                effectUnit1Assign: {inByte: 3, inBit: 3, outByte: 78},
                effectUnit2Assign: {inByte: 3, inBit: 4, outByte: 79},
                gain: {inByte: 17},
                eqHigh: {inByte: 45},
                eqMid: {inByte: 47},
                eqLow: {inByte: 49},
                quickEffectKnob: {inByte: 65},
                quickEffectButton: {},
                volume: {inByte: 3},
                pfl: {inByte: 8, inBit: 3, outByte: 77},
                crossfaderSwitch: {inByte: 18, inBit: 4},
            }
        );
        this.mixerColumnDeck2 = new S4Mk3MixerColumn("[Channel2]", inPackets, outPackets[128],
            {
                saveGain: {inByte: 12, inBit: 1, outByte: 84},
                effectUnit1Assign: {inByte: 3, inBit: 5, outByte: 82},
                effectUnit2Assign: {inByte: 3, inBit: 6, outByte: 83},
                gain: {inByte: 19},
                eqHigh: {inByte: 51},
                eqMid: {inByte: 53},
                eqLow: {inByte: 55},
                quickEffectKnob: {inByte: 67},
                volume: {inByte: 5},
                pfl: {inByte: 8, inBit: 6, outByte: 81},
                crossfaderSwitch: {inByte: 18, inBit: 2},
            }
        );
        this.mixerColumnDeck3 = new S4Mk3MixerColumn("[Channel3]", inPackets, outPackets[128],
            {
                saveGain: {inByte: 3, inBit: 1, outByte: 88},
                effectUnit1Assign: {inByte: 3, inBit: 0, outByte: 86},
                effectUnit2Assign: {inByte: 3, inBit: 2, outByte: 87},
                gain: {inByte: 15},
                eqHigh: {inByte: 39},
                eqMid: {inByte: 41},
                eqLow: {inByte: 43},
                quickEffectKnob: {inByte: 63},
                volume: {inByte: 7},
                pfl: {inByte: 8, inBit: 2, outByte: 85},
                crossfaderSwitch: {inByte: 18, inBit: 6},
            }
        );
        this.mixerColumnDeck4 = new S4Mk3MixerColumn("[Channel4]", inPackets, outPackets[128],
            {
                saveGain: {inByte: 12, inBit: 2, outByte: 92},
                effectUnit1Assign: {inByte: 3, inBit: 7, outByte: 90},
                effectUnit2Assign: {inByte: 12, inBit: 7, outByte: 91},
                gain: {inByte: 21},
                eqHigh: {inByte: 57},
                eqMid: {inByte: 59},
                eqLow: {inByte: 61},
                quickEffectKnob: {inByte: 69},
                volume: {inByte: 9},
                pfl: {inByte: 8, inBit: 7, outByte: 89},
                crossfaderSwitch: {inByte: 18, inBit: 0},
            }
        );

        this.firstPressedFxSelector = null;
        this.secondPressedFxSelector = null;
        this.comboSelected = false;

        const fxSelectsInputs = [
            {inByte: 9, inBit: 5},
            {inByte: 9, inBit: 1},
            {inByte: 9, inBit: 6},
            {inByte: 9, inBit: 0},
            {inByte: 9, inBit: 7},
        ];
        this.fxSelects = [];
        for (const i of [0, 1, 2, 3, 4]) {
            this.fxSelects[i] = new FXSelect(
                Object.assign(fxSelectsInputs[i], {
                    number: i + 1,
                    mixer: this,
                })
            );
        }

        const quickEffectInputs = [
            {inByte: 8, inBit: 0, outByte: 46},
            {inByte: 8, inBit: 5, outByte: 47},
            {inByte: 8, inBit: 1, outByte: 48},
            {inByte: 8, inBit: 4, outByte: 49},
        ];
        this.quickEffectButtons = [];
        for (const i of [0, 1, 2, 3]) {
            this.quickEffectButtons[i] = new QuickEffectButton(
                Object.assign(quickEffectInputs[i], {
                    number: i + 1,
                    mixer: this,
                })
            );
        }
        this.resetFxSelectorColors();

        this.quantizeButton = new Button({
            input: function(pressed) {
                if (pressed) {
                    this.globalQuantizeOn = !this.globalQuantizeOn;
                    for (let i = 1; i <= 4; i++) {
                        engine.setValue("[Channel" + i + "]", "quantize", this.globalQuantizeOn);
                    }
                    this.send(this.globalQuantizeOn ? 127 : 0);
                }
            },
            globalQuantizeOn: false,
            inByte: 12,
            inBit: 6,
            outByte: 93,
        });

        this.crossfader = new Pot({
            group: "[Master]",
            inKey: "crossfader",
            inByte: 1,
            inPacket: inPackets[2],
        });
        this.crossfaderCurveSwitch = new Component({
            inByte: 19,
            inBit: 0,
            inBitLength: 2,
            input: function(value) {
                switch (value) {
                case 0x00:  // Picnic Bench / Fast Cut
                    engine.setValue("[Mixer Profile]", "xFaderMode", 0);
                    engine.setValue("[Mixer Profile]", "xFaderCalibration", 0.9);
                    engine.setValue("[Mixer Profile]", "xFaderCurve", 7.0);
                    break;
                case 0x01:  // Constant Power
                    engine.setValue("[Mixer Profile]", "xFaderMode", 1);
                    engine.setValue("[Mixer Profile]", "xFaderCalibration", 0.3);
                    engine.setValue("[Mixer Profile]", "xFaderCurve", 0.6);
                    break;
                case 0x02: // Additive
                    engine.setValue("[Mixer Profile]", "xFaderMode", 0);
                    engine.setValue("[Mixer Profile]", "xFaderCalibration", 0.4);
                    engine.setValue("[Mixer Profile]", "xFaderCurve", 0.9);
                }
            },
        });

        for (const component of this) {
            if (component.inPacket === undefined) {
                component.inPacket = inPackets[1];
            }
            component.outPacket = this.outPacket;
            component.inConnect();
            component.outConnect();
            component.outTrigger();
        }

        let lightQuantizeButton = true;
        for (let i = 1; i <= 4; i++) {
            if (!engine.getValue("[Channel" + i + "]", "quantize")) {
                lightQuantizeButton = false;
            }
        }
        this.quantizeButton.send(lightQuantizeButton ? 127 : 0);
        this.quantizeButton.globalQuantizeOn = lightQuantizeButton;
    }

    calculatePresetNumber() {
        if (this.firstPressedFxSelector === this.secondPressedFxSelector || this.secondPressedFxSelector === null) {
            return this.firstPressedFxSelector;
        }
        let presetNumber = 5 + (4 * (this.firstPressedFxSelector - 1)) + this.secondPressedFxSelector;
        if (this.secondPressedFxSelector > this.firstPressedFxSelector) {
            presetNumber--;
        }
        return presetNumber;
    }

    resetFxSelectorColors() {
        for (const selector of [1, 2, 3, 4, 5]) {
            this.outPacket.data[49 + selector] = QuickEffectPresetColors[selector - 1] + Button.prototype.brightnessOn;
        }
        this.outPacket.send();
    }
}

class FXSelect extends Button {
    constructor(options) {
        super(options);

        if (this.mixer === undefined) {
            throw Error("The mixer must be specified");
        }
    }

    onShortPress() {
        if (this.mixer.firstPressedFxSelector === null) {
            this.mixer.firstPressedFxSelector = this.number;
            for (const selector of [1, 2, 3, 4, 5]) {
                if (selector !== this.number) {
                    let presetNumber = 5 + (4 * (this.mixer.firstPressedFxSelector - 1)) + selector;
                    if (selector > this.number) {
                        presetNumber--;
                    }
                    this.outPacket.data[49 + selector] = QuickEffectPresetColors[presetNumber - 1] + this.brightnessOn;
                }
            }
            this.outPacket.send();
        } else {
            this.mixer.secondPressedFxSelector = this.number;
        }

    }

    onShortRelease() {
        // After a second selector was released, avoid loading a different preset when
        // releasing the first pressed selector.
        if (this.mixer.comboSelected && this.number === this.mixer.firstPressedFxSelector) {
            this.mixer.comboSelected = false;
            this.mixer.firstPressedFxSelector = null;
            this.mixer.secondPressedFxSelector = null;
            this.mixer.resetFxSelectorColors();
            return;
        }
        // If mixer.firstPressedFxSelector === null, it was reset by the input handler for
        // a QuickEffect enable button to load the preset for only one deck.
        if (this.mixer.firstPressedFxSelector !== null) {
            for (const deck of [1, 2, 3, 4]) {
                const presetNumber = this.mixer.calculatePresetNumber();
                engine.setValue("[QuickEffectRack1_[Channel" + deck + "]]", "loaded_chain_preset", presetNumber + 1);
            }
        }
        if (this.mixer.firstPressedFxSelector === this.number) {
            this.mixer.firstPressedFxSelector = null;
            this.mixer.resetFxSelectorColors();
        }
        if (this.mixer.secondPressedFxSelector !== null) {
            this.mixer.comboSelected = true;
        }
        this.mixer.secondPressedFxSelector = null;
    }

}


class QuickEffectButton extends Button {
    constructor(options) {
        super(options);
        if (this.mixer === undefined) {
            throw Error("The mixer must be specified");
        }
        if (this.number === undefined || !Number.isInteger(this.number) || this.number < 1) {
            throw Error("number attribute must be an integer >= 1");
        }
        this.group = "[QuickEffectRack1_[Channel" + this.number + "]]";
        this.outConnect();
    }
    onShortPress() {
        if (this.mixer.firstPressedFxSelector === null) {
            script.toggleControl(this.group, "enabled");
        } else {
            const presetNumber = this.mixer.calculatePresetNumber();
            this.color = QuickEffectPresetColors[presetNumber - 1];
            engine.setValue(this.group, "loaded_chain_preset", presetNumber + 1);
            this.mixer.firstPressedFxSelector = null;
            this.mixer.secondPressedFxSelector = null;
            this.mixer.resetFxSelectorColors();
        }
    }
    onLongRelease() {
        if (this.mixer.firstPressedFxSelector === null) {
            script.toggleControl(this.group, "enabled");
        }
    }
    output(enabled) {
        if (enabled) {
            this.send(this.color + this.brightnessOn);
        } else {
            // It is easy to mistake the dim state for the bright state, so turn
            // the LED fully off.
            this.send(this.color + this.brightnessOff);
        }
    }
    presetLoaded(presetNumber) {
        this.color = QuickEffectPresetColors[presetNumber - 2];
        this.outConnections[1].trigger();
    }
    outConnect() {
        if (this.group !== undefined) {
            const connection0 = engine.makeConnection(this.group, "loaded_chain_preset", this.presetLoaded.bind(this));
            if (connection0) {
                this.outConnections[0] = connection0;
            } else {
                console.warn("Unable to connect '" + this.group + ".loaded_chain_preset' to the controller output. The control appears to be unavailable.");
            }
            const connection1 = engine.makeConnection(this.group, "enabled", this.output.bind(this));
            if (connection1) {
                this.outConnections[1] = connection1;
            } else {
                console.warn("Unable to connect '" + this.group + ".enabled' to the controller output. The control appears to be unavailable.");
            }
        }
    }
}

/*
 * Kontrol S4 Mk3 hardware-specific constants
 */

Pot.prototype.max = 2 ** 12 - 1;
Pot.prototype.inBit = 0;
Pot.prototype.inBitLength = 16;

Encoder.prototype.inBitLength = 4;

// valid range 0 - 3, but 3 makes some colors appear whitish
Button.prototype.brightnessOff = 0;
Button.prototype.brightnessOn = 2;
Button.prototype.uncoloredOutput = function(value) {
    if (this.indicatorTimer !== 0) {
        return;
    }
    const color = (value > 0) ? (this.color || LedColors.white) + this.brightnessOn : LedColors.off;
    this.send(color);
};
Button.prototype.colorMap = new ColorMapper({
    0xCC0000: LedColors.red,
    0xCC5E00: LedColors.carrot,
    0xCC7800: LedColors.orange,
    0xCC9200: LedColors.honey,

    0xCCCC00: LedColors.yellow,
    0x81CC00: LedColors.lime,
    0x00CC00: LedColors.green,
    0x00CC49: LedColors.aqua,

    0x00CCCC: LedColors.celeste,
    0x0091CC: LedColors.sky,
    0x0000CC: LedColors.blue,
    0xCC00CC: LedColors.purple,

    0xCC0091: LedColors.fuscia,
    0xCC0079: LedColors.magenta,
    0xCC477E: LedColors.azalea,
    0xCC4761: LedColors.salmon,

    0xCCCCCC: LedColors.white,
});

const wheelRelativeMax = 2 ** 16 - 1;
const wheelAbsoluteMax = 2879;

const wheelTimerMax = 2 ** 32 - 1;
const wheelTimerTicksPerSecond = 100000000;

const baseRevolutionsPerSecond = BaseRevolutionsPerMinute / 60;
const wheelTicksPerTimerTicksToRevolutionsPerSecond = wheelTimerTicksPerSecond / wheelAbsoluteMax;

const wheelLEDmodes = {
    off: 0,
    dimFlash: 1,
    spot: 2,
    ringFlash: 3,
    dimSpot: 4,
    individuallyAddressable: 5, // set byte 4 to 0 and set byes 8 - 40 to color values
};

// The mode available, which the wheel can be used for.
const wheelModes = {
    jog: 0,
    vinyl: 1,
    motor: 2,
    loopIn: 3,
    loopOut: 4,
};

const moveModes = {
    beat: 0,
    bpm: 1,
    grid: 2,
    keyboard: 3,
};

// tracks state across input packets
let wheelTimer = null;
// This is a global variable so the S4Mk3Deck Components have access
// to it and it is guaranteed to be calculated before processing
// input for the Components.
let wheelTimerDelta = 0;

/*
 * Kontrol S4 Mk3 hardware specific mapping logic
 */

class S4Mk3EffectUnit extends ComponentContainer {
    constructor(unitNumber, inPackets, outPacket, io) {
        super();
        this.group = "[EffectRack1_EffectUnit" + unitNumber + "]";
        this.unitNumber = unitNumber;
        this.focusedEffect = null;

        this.mixKnob = new Pot({
            inKey: "mix",
            group: this.group,
            inPacket: inPackets[2],
            inByte: io.mixKnob.inByte,
        });

        this.mainButton = new PowerWindowButton({
            unit: this,
            inPacket: inPackets[1],
            inByte: io.mainButton.inByte,
            inBit: io.mainButton.inBit,
            outByte: io.mainButton.outByte,
            outPacket: outPacket,
            shift: function() {
                this.group = this.unit.group;
                this.outKey = "group_[Master]_enable";
                this.outConnect();
                this.outTrigger();
            },
            unshift: function() {
                this.outDisconnect();
                this.outKey = undefined;
                this.group = undefined;
                this.output(false);
            },
            input: function(pressed) {
                if (!this.shifted) {
                    for (const index of [0, 1, 2]) {
                        const effectGroup = "[EffectRack1_EffectUnit" + unitNumber + "_Effect" + (index + 1) + "]";
                        engine.setValue(effectGroup, "enabled", pressed);
                    }
                    this.output(pressed);
                } else if (pressed) {
                    if (this.unit.focusedEffect !== null) {
                        this.unit.setFocusedEffect(null);
                    } else {
                        script.toggleControl(this.unit.group, "group_[Master]_enable");
                        this.shift();
                    }
                }
            }
        });

        this.knobs = [];
        this.buttons = [];
        for (const index of [0, 1, 2]) {
            const effectGroup = "[EffectRack1_EffectUnit" + unitNumber + "_Effect" + (index + 1) + "]";
            this.knobs[index] = new Pot({
                inKey: "meta",
                group: effectGroup,
                inPacket: inPackets[2],
                inByte: io.knobs[index].inByte,
            });
            this.buttons[index] = new Button({
                unit: this,
                key: "enabled",
                group: effectGroup,
                inPacket: inPackets[1],
                inByte: io.buttons[index].inByte,
                inBit: io.buttons[index].inBit,
                outByte: io.buttons[index].outByte,
                outPacket: outPacket,
                onShortPress: function() {
                    if (!this.shifted || this.unit.focusedEffect !== null) {
                        script.toggleControl(this.group, this.inKey);
                    }
                },
                onLongPress: function() {
                    if (this.shifted) {
                        this.unit.setFocusedEffect(index);
                    }
                },
                onShortRelease: function() {
                    if (this.shifted && this.unit.focusedEffect === null) {
                        script.triggerControl(this.group, "next_effect");
                    }
                },
                onLongRelease: function() {
                    if (!this.shifted) {
                        script.toggleControl(this.group, this.inKey);
                    }
                }
            });
        }

        for (const component of this) {
            component.inConnect();
            component.outConnect();
            component.outTrigger();
        }
    }
    indicatorLoop() {
        this.focusedEffectIndicator = !this.focusedEffectIndicator;
        this.mainButton.output(true);
    }
    setFocusedEffect(effectIdx) {
        this.mainButton.indicator(effectIdx !== null);
        this.focusedEffect = effectIdx;
        engine.setValue(this.group, "show_parameters", this.focusedEffect !== null);


        const effectGroup = "[EffectRack1_EffectUnit" + this.unitNumber + "_Effect" + (this.focusedEffect + 1) + "]";
        for (const index of [0, 1, 2]) {
            const unfocusGroup = "[EffectRack1_EffectUnit" + this.unitNumber + "_Effect" + (index + 1) + "]";
            this.buttons[index].outDisconnect();
            this.buttons[index].group = this.focusedEffect === null ? unfocusGroup : effectGroup;
            this.buttons[index].inKey = this.focusedEffect === null ? "enabled" : "button_parameter" + (index + 1);
            this.buttons[index].shift = this.focusedEffect === null ? undefined : function() {
                this.setGroup(unfocusGroup);
                this.setKey("enabled");
            };
            this.buttons[index].unshift = this.focusedEffect === null ? undefined : function() {
                this.setGroup(effectGroup);
                this.setKey("button_parameter" + (index + 1));
            };
            this.buttons[index].outKey = this.buttons[index].inKey;
            this.knobs[index].group = this.buttons[index].group;
            this.knobs[index].inKey = this.focusedEffect === null ? "meta" : "parameter" + (index + 1);
            this.knobs[index].shift = this.focusedEffect === null ? undefined : function() {
                this.setGroupKey(unfocusGroup, "meta");
            };
            this.knobs[index].unshift = this.focusedEffect === null ? undefined : function() {
                this.setGroupKey(effectGroup, "parameter" + (index + 1));
            };
            this.buttons[index].outConnect();
        }
    }
}

class S4Mk3Deck extends Deck {
    constructor(decks, colors, deckId, effectUnit, inPackets, outPacket, io) {
        super(decks, colors, deckId);

        this.playButton = new PlayButton({
            output: KeepLEDWithOneColorDimedWhenInactive ? undefined : Button.prototype.uncoloredOutput
        });

        this.cueButton = new CueButton({
            deck: this
        });
        this.effectUnit = effectUnit;

        this.syncMasterButton = new Button({
            key: "sync_leader",
            defaultRange: 0.08,
            shift: UseKeylockOnMaster ? function() {
                this.setKey("keylock");
            } : undefined,
            unshift: UseKeylockOnMaster ? function() {
                this.setKey("sync_leader");
            } : undefined,
            onShortRelease: function() {
                script.toggleControl(this.group, this.inKey);
            },
            onLongPress: function() {
                const currentRange = engine.getValue(this.group, "rateRange");
                if (currentRange < 1.0) {
                    engine.setValue(this.group, "rateRange", 1.0);
                    this.indicator(true);
                } else {
                    engine.setValue(this.group, "rateRange", this.defaultRange);
                    this.indicator(false);
                }
            },
        });
        this.syncButton = new Button({
            key: "sync_enabled",
            onLongPress: function() {
                if (this.shifted) {
                    engine.setValue(this.group, "sync_key", true);
                    engine.setValue(this.group, "sync_key", false);
                } else {
                    script.triggerControl(this.group, "beatsync_tempo");
                }
            },
            onShortRelease: function() {
                script.toggleControl(this.group, this.inKey);
                if (!this.shifted) {
                    engine.softTakeover(this.group, "rate", true);
                }
            },
            shift: !UseKeylockOnMaster ? function() {
                this.setKey("keylock");
            } : undefined,
            unshift: !UseKeylockOnMaster ? function() {
                this.setKey("sync_enabled");
            } : undefined,
        });
        this.tempoFader = new Pot({
            inKey: "rate",
        });
        this.tempoFaderLED = new Component({
            outKey: "rate",
            centered: false,
            toleranceWindow: 0.001,
            tempoFader: this.tempoFader,
            output: function(value) {
                if (this.tempoFader.hardwarePosition === null) {
                    return;
                }

                const parameterValue = engine.getParameter(this.group, this.outKey);
                const diffFromHardware = parameterValue - this.tempoFader.hardwarePosition;
                if (diffFromHardware > this.toleranceWindow) {
                    this.send(TempoFaderSoftTakeoverColorHigh + Button.prototype.brightnessOn);
                    return;
                } else if (diffFromHardware < (-1 * this.toleranceWindow)) {
                    this.send(TempoFaderSoftTakeoverColorLow + Button.prototype.brightnessOn);
                    return;
                }

                const oldCentered = this.centered;
                if (Math.abs(value) < 0.001) {
                    this.send(this.color + Button.prototype.brightnessOn);
                    // round to precisely 0
                    engine.setValue(this.group, "rate", 0);
                } else {
                    this.send(0);
                }
            }
        });

        this.reverseButton = new Button({
            key: "reverseroll",
            deck: this,
            previousWheelMode: null,
            loopModeConnection: null,
            unshift: function() {
                this.setKey("reverseroll");

            },
            shift: function() {
                this.setKey("loop_enabled");
            },
            output: KeepLEDWithOneColorDimedWhenInactive ? undefined : Button.prototype.uncoloredOutput,
            onShortRelease: function() {
                if (!this.shifted) {
                    engine.setValue(this.group, this.key, false);
                }
            },
            loopModeOff: function(skipRestore) {
                if (this.previousWheelMode !== null) {
                    this.indicator(false);
                    const wheelOutput = Array(40).fill(0);
                    wheelOutput[0] = decks[0] - 1;
                    const that = this;
                    controller.send(wheelOutput, null, 50, true);
                    if (!skipRestore) {
                        that.deck.wheelMode = that.previousWheelMode;
                    }
                    that.previousWheelMode = null;
                    if (this.loopModeConnection !== null) {
                        this.loopModeConnection.disconnect();
                        this.loopModeConnection = null;
                    }
                }
            },
            onLoopChange: function(loopEnabled) {
                if (loopEnabled) { return; }
                this.loopModeOff();
            },
            onShortPress: function() {
                this.indicator(false);
                if (this.shifted) {
                    const loopEnabled = engine.getValue(this.group, "loop_enabled");
                    // If there is currently no loop, we set the loop in of a new loop
                    if (!loopEnabled) {
                        engine.setValue(this.group, "loop_end_position", -1);
                        engine.setValue(this.group, "loop_in", true);
                        this.indicator(true);
                        // Else, we enter/exit the loop in wheel mode
                    } else if (this.previousWheelMode === null) {
                        this.deck.fluxButton.loopModeOff();
                        engine.setValue(this.group, "scratch2_enable", false);
                        this.previousWheelMode = this.deck.wheelMode;
                        this.deck.wheelMode = wheelModes.loopIn;

                        if (this.loopModeConnection === null) {
                            this.loopModeConnection = engine.makeConnection(this.group, this.outKey, this.onLoopChange.bind(this));
                        }

                        const wheelOutput = Array(40).fill(0);
                        wheelOutput[0] = decks[0] - 1;
                        wheelOutput[1] = wheelLEDmodes.ringFlash;
                        wheelOutput[4] = this.color + Button.prototype.brightnessOn;

                        controller.send(wheelOutput, null, 50, true);

                        this.indicator(true);
                    } else if (this.previousWheelMode !== null) {
                        this.loopModeOff();
                    }
                } else {
                    engine.setValue(this.group, this.key, true);
                }
            }
        });
        this.fluxButton = new Button({
            key: "slip_enabled",
            deck: this,
            previousWheelMode: null,
            loopModeConnection: null,
            unshift: function() {
                this.setKey("slip_enabled");

            },
            shift: function() {
                this.setKey("loop_enabled");
            },
            outConnect: function() {
                if (this.outKey !== undefined && this.group !== undefined) {
                    const connection = engine.makeConnection(this.group, this.outKey, this.output.bind(this));
                    if (connection) {
                        this.outConnections[0] = connection;
                    } else {
                        console.warn("Unable to connect '" + this.group + "." + this.outKey + "' to the controller output. The control appears to be unavailable.");
                    }
                }
            },
            output: KeepLEDWithOneColorDimedWhenInactive ? undefined : Button.prototype.uncoloredOutput,
            onShortRelease: function() {
                if (!this.shifted) {
                    engine.setValue(this.group, this.key, false);
                    engine.setValue(this.group, "scratch2_enable", false);
                }
            },
            loopModeOff: function(skipRestore) {
                if (this.previousWheelMode !== null) {
                    this.indicator(false);
                    const wheelOutput = Array(40).fill(0);
                    wheelOutput[0] = decks[0] - 1;
                    const that = this;
                    controller.send(wheelOutput, null, 50, true);
                    if (!skipRestore) {
                        that.deck.wheelMode = that.previousWheelMode;
                    }
                    that.previousWheelMode = null;
                    if (this.loopModeConnection !== null) {
                        this.loopModeConnection.disconnect();
                        this.loopModeConnection = null;
                    }
                }
            },
            onLoopChange: function(loopEnabled) {
                if (loopEnabled) { return; }
                this.loopModeOff();
            },
            onShortPress: function() {
                this.indicator(false);
                if (this.shifted) {
                    const loopEnabled = engine.getValue(this.group, "loop_enabled");
                    // If there is currently no loop, we set the loop in of a new loop
                    if (!loopEnabled) {
                        engine.setValue(this.group, "loop_out", true);
                        this.deck.reverseButton.indicator(false);
                        // Else, we enter/exit the loop in wheel mode
                    } else if (this.previousWheelMode === null) {
                        this.deck.reverseButton.loopModeOff();
                        engine.setValue(this.group, "scratch2_enable", false);
                        this.previousWheelMode = this.deck.wheelMode;
                        this.deck.wheelMode = wheelModes.loopOut;
                        if (this.loopModeConnection === null) {
                            this.loopModeConnection = engine.makeConnection(this.group, this.outKey, this.onLoopChange.bind(this));
                        }

                        const wheelOutput = Array(40).fill(0);
                        wheelOutput[0] = decks[0] - 1;
                        wheelOutput[1] = wheelLEDmodes.ringFlash;
                        wheelOutput[4] = this.color + Button.prototype.brightnessOn;

                        controller.send(wheelOutput, null, 50, true);

                        this.indicator(true);
                    } else if (this.previousWheelMode !== null) {
                        this.loopModeOff();
                    }
                } else {
                    engine.setValue(this.group, this.key, true);
                }
            }
        });
        this.gridButton = new Button({
            key: GridButtonBlinkOverBeat ? "beat_active" : undefined,
            deck: this,
            previousMoveMode: null,
            unshift: !GridButtonBlinkOverBeat ? function() {
                this.output(false);
            } : undefined,
            onShortPress: function() {
                this.deck.libraryEncoder.gridButtonPressed = true;
            },
            onLongPress: function() {
                this.deck.libraryEncoder.gridButtonPressed = true;
                this.previousMoveMode = this.deck.moveMode;

                if (this.shifted) {
                    this.deck.moveMode = moveModes.grid;
                } else {
                    this.deck.moveMode = moveModes.bpm;
                }

                this.indicator(true);
            },
            onLongRelease: function() {
                this.deck.libraryEncoder.gridButtonPressed = false;
                if (this.previousMoveMode !== null) {
                    this.deck.moveMode = this.previousMoveMode;
                    this.previousMoveMode = null;
                }
                this.indicator(false);
            },
            onShortRelease: function() {
                this.deck.libraryEncoder.gridButtonPressed = false;
                script.triggerControl(this.group, "beats_translate_curpos");
            },
        });

        this.deckButtonLeft = new Button({
            deck: this,
            input: function(value) {
                if (value) {
                    this.deck.switchDeck(Deck.groupForNumber(decks[0]));
                    this.outPacket.data[io.deckButtonOutputByteOffset] = colors[0] + this.brightnessOn;
                    // turn off the other deck selection button's LED
                    this.outPacket.data[io.deckButtonOutputByteOffset + 1] = KeepDeckSelectDimmed ? colors[1] + this.brightnessOff : 0;
                    this.outPacket.send();
                }
            },
        });
        this.deckButtonRight = new Button({
            deck: this,
            input: function(value) {
                if (value) {
                    this.deck.switchDeck(Deck.groupForNumber(decks[1]));
                    // turn off the other deck selection button's LED
                    this.outPacket.data[io.deckButtonOutputByteOffset] = KeepDeckSelectDimmed ? colors[0] + this.brightnessOff : 0;
                    this.outPacket.data[io.deckButtonOutputByteOffset + 1] = colors[1] + this.brightnessOn;
                    this.outPacket.send();
                }
            },
        });

        // set deck selection button LEDs
        outPacket.data[io.deckButtonOutputByteOffset] = colors[0] + Button.prototype.brightnessOn;
        outPacket.data[io.deckButtonOutputByteOffset + 1] = KeepDeckSelectDimmed ? colors[1] + Button.prototype.brightnessOff : 0;
        outPacket.send();

        this.shiftButton = new PushButton({
            deck: this,
            output: KeepLEDWithOneColorDimedWhenInactive ? undefined : Button.prototype.uncoloredOutput,
            unshift: function() {
                this.output(false);
            },
            shift: function() {
                this.output(true);
            },
            input: function(pressed) {
                if (pressed) {
                    this.deck.shift();
                } else {
                    this.deck.unshift();
                }
            }
        });

        this.leftEncoder = new Encoder({
            deck: this,
            onChange: function(right) {

                switch (this.deck.moveMode) {
                case moveModes.grid:
                    script.triggerControl(this.group, right ? "beats_adjust_faster" : "beats_adjust_slower");
                    break;
                case moveModes.keyboard:
                    if (
                        this.deck.keyboard[0].offset === (right ? 16 : 0)
                    ) {
                        return;
                    }
                    this.deck.keyboardOffset += (right ? 1 : -1);
                    this.deck.keyboard.forEach(function(pad) {
                        pad.outTrigger();
                    });
                    break;
                case moveModes.bpm:
                    script.triggerControl(this.group, right ? "beats_translate_later" : "beats_translate_earlier");
                    break;
                default:
                    if (!this.shifted) {
                        if (!this.deck.leftEncoderPress.pressed) {
                            if (right) {
                                script.triggerControl(this.group, "beatjump_forward");
                            } else {
                                script.triggerControl(this.group, "beatjump_backward");
                            }
                        } else {
                            let beatjumpSize = engine.getValue(this.group, "beatjump_size");
                            if (right) {
                                beatjumpSize *= 2;
                            } else {
                                beatjumpSize /= 2;
                            }
                            engine.setValue(this.group, "beatjump_size", beatjumpSize);
                        }
                    } else {
                        if (right) {
                            script.triggerControl(this.group, "pitch_up_small");
                        } else {
                            script.triggerControl(this.group, "pitch_down_small");
                        }
                    }
                    break;
                }
            }
        });
        this.leftEncoderPress = new PushButton({
            deck: this,
            input: function(pressed) {
                this.pressed = pressed;
                if (pressed) {
                    script.toggleControl(this.group, "pitch_adjust_set_default");
                }

                const runtimeData = engine.getRuntimeData();
                runtimeData.displayBeatloopSize[this.deck.deckId] = pressed;
                engine.setRuntimeData(runtimeData);
            },
        });

        this.rightEncoder = new Encoder({
            deck: this,
            onChange: function(right) {
                if (this.deck.wheelMode === wheelModes.loopIn || this.deck.wheelMode === wheelModes.loopOut) {
                    const moveFactor = this.shifted ? LOOP_ENCODER_SHIFTMOVE_FACTOR : LOOP_ENCODER_MOVE_FACTOR;
                    const valueIn = engine.getValue(this.group, "loop_start_position") + (right ? moveFactor : -moveFactor);
                    const valueOut = engine.getValue(this.group, "loop_end_position") + (right ? moveFactor : -moveFactor);
                    engine.setValue(this.group, "loop_start_position", valueIn);
                    engine.setValue(this.group, "loop_end_position", valueOut);
                } else if (this.shifted) {
                    script.triggerControl(this.group, right ? "loop_move_1_forward" : "loop_move_1_backward");
                } else {
                    script.triggerControl(this.group, right ? "loop_double" : "loop_halve");
                }
            }
        });
        this.rightEncoderPress = new PushButton({
            input: function(pressed) {
                if (!pressed) {
                    return;
                }
                const loopEnabled = engine.getValue(this.group, "loop_enabled");
                if (!this.shifted) {
                    script.triggerControl(this.group, "beatloop_activate");
                } else {
                    script.triggerControl(this.group, "reloop_toggle");
                }
            },
        });

        this.libraryEncoder = new Encoder({
            libraryPlayButtonPressed: false,
            gridButtonPressed: false,
            starButtonPressed: false,
            libraryViewButtonPressed: false,
            libraryPlaylistButtonPressed: false,
            currentSortedColumnIdx: -1,
            onChange: function(right) {
                if (this.libraryViewButtonPressed) {
                    this.currentSortedColumnIdx = (this.currentSortedColumnIdx + (right ? 1 : -1)) % LibrarySortableColumns.length;
                    engine.setValue("[Library]", "sort_column", LibrarySortableColumns[this.currentSortedColumnIdx]);
                } else if (this.starButtonPressed) {
                    if (this.shifted) {
                        // FIXME doesn't exist, feature request needed
                        script.triggerControl(this.group, right ? "track_color_prev" : "track_color_next");
                    } else {
                        script.triggerControl(this.group, right ? "stars_up" : "stars_down");
                    }
                } else if (this.gridButtonPressed) {
                    script.triggerControl(this.group, right ? "waveform_zoom_up" : "waveform_zoom_down");
                } else if (this.libraryPlayButtonPressed) {
                    script.triggerControl("[PreviewDeck1]", right ? "beatjump_16_forward" : "beatjump_16_backward");
                } else {
                    // FIXME there is a bug where this action has no effect when the Mixxx window has no focused. https://github.com/mixxxdj/mixxx/issues/11285
                    // As a workaround, we are using deprecated control, hoping the bug will be fixed before the controls get removed
                    const currentlyFocusWidget = engine.getValue("[Library]", "focused_widget");
                    if (currentlyFocusWidget === 0) {
                        if (this.shifted) {
                            script.triggerControl("[Playlist]", right ? "SelectNextPlaylist" : "SelectPrevPlaylist");
                        } else {
                            script.triggerControl("[Playlist]", right ? "SelectNextTrack" : "SelectPrevTrack");
                        }
                    } else {
                        engine.setValue("[Library]", "focused_widget", this.shifted ? 2 : 3);
                        engine.setValue("[Library]", "MoveVertical", right ? 1 : -1);
                    }
                }
            }
        });
        this.libraryEncoderPress = new Button({
            libraryViewButtonPressed: false,
            onShortPress: function(pressed) {
                if (this.libraryViewButtonPressed) {
                    script.toggleControl("[Library]", "sort_order");
                } else {
                    const currentlyFocusWidget = engine.getValue("[Library]", "focused_widget");
                    // 3 == Tracks table or root views of library features
                    if (this.shifted && currentlyFocusWidget === 0) {
                        script.triggerControl("[Playlist]", "ToggleSelectedSidebarItem");
                    } else if (currentlyFocusWidget === 3 || currentlyFocusWidget === 0) {
                        script.triggerControl(this.group, "LoadSelectedTrack");
                    } else {
                        script.triggerControl("[Library]", "GoToItem");
                    }
                }
            },
            // FIXME not supported, feature request
            // onLongPress: function(){
            //     script.triggerControl("[Library]", "search_related_track", engine.getValue("[Library]", "sort_column"));
            // }
        });
        this.libraryPlayButton = new PushButton({
            group: "[PreviewDeck1]",
            libraryEncoder: this.libraryEncoder,
            input: function(pressed) {
                if (pressed) {
                    script.triggerControl(this.group, "LoadSelectedTrackAndPlay");
                } else {
                    engine.setValue(this.group, "play", 0);
                    script.triggerControl(this.group, "eject");
                }
                this.libraryEncoder.libraryPlayButtonPressed = pressed;
            },
            outKey: "play",
        });
        this.libraryStarButton = new Button({
            group: "[Library]",
            libraryEncoder: this.libraryEncoder,
            onShortRelease: function() {
                script.triggerControl(this.group, this.shifted ? "track_color_prev" : "track_color_next");
            },
            onLongPress: function() {
                this.libraryEncoder.starButtonPressed = true;
            },
            onLongRelease: function() {
                this.libraryEncoder.starButtonPressed = false;
            },
        });
        // FIXME there is no feature about playlist at the moment, so we use this button to control the context menu, which has playlist control
        this.libraryPlaylistButton = new Button({
            group: "[Library]",
            libraryEncoder: this.libraryEncoder,
            outConnect: function() {
                const connection = engine.makeConnection(this.group, "focused_widget", (widget) => {
                    // 4 == Context menu
                    this.output(widget === 4);
                });
                // This is useful for case where effect would have been fully disabled in Mixxx. This appears to be the case during unit tests.
                if (connection) {
                    this.outConnections[0] = connection;
                } else {
                    console.warn("Unable to connect '" + this.group + ".focused_widget' to the controller output. The control appears to be unavailable.");
                }
            },
            onShortRelease: function() {
                const currentlyFocusWidget = engine.getValue("[Library]", "focused_widget");
                // 3 == Tracks table or root views of library features
                // 4 == Context menu
                if (currentlyFocusWidget !== 3 && currentlyFocusWidget !== 4) {
                    return;
                }
                script.toggleControl("[Library]", "show_track_menu");
                this.libraryEncoder.libraryPlayButtonPressed = false;

                if (currentlyFocusWidget === 4) {
                    engine.setValue("[Library]", "focused_widget", 3);
                }
            },
            onShortPress: function() {
                this.libraryEncoder.libraryPlayButtonPressed = true;
            },
            onLongRelease: function() {
                this.libraryEncoder.libraryPlayButtonPressed = false;
            },
            onLongPress: function() {
                engine.setValue("[Library]", "clear_search", 1);
            }
        });
        this.libraryViewButton = new Button({
            group: "[Master]",
            key: "maximize_library",
            libraryEncoder: this.libraryEncoder,
            libraryEncoderPress: this.libraryEncoderPress,
            onShortRelease: function() {
                script.toggleControl(this.group, this.inKey, true);
            },
            onLongPress: function() {
                this.libraryEncoder.libraryViewButtonPressed = true;
                this.libraryEncoderPress.libraryViewButtonPressed = true;
            },
            onLongRelease: function() {
                this.libraryEncoder.libraryViewButtonPressed = false;
                this.libraryEncoderPress.libraryViewButtonPressed = false;
            }
        });

        this.keyboardPlayMode = null;
        this.keyboardOffset = 9;

        this.pads = Array(8).fill(new Component());
        const defaultPadLayer = [
            new IntroOutroButton({
                cueBaseName: "intro_start",
            }),
            new IntroOutroButton({
                cueBaseName: "intro_end",
            }),
            new IntroOutroButton({
                cueBaseName: "outro_start",
            }),
            new IntroOutroButton({
                cueBaseName: "outro_end",
            }),
            new HotcueButton({
                number: 1
            }),
            new HotcueButton({
                number: 2
            }),
            new HotcueButton({
                number: 3
            }),
            new HotcueButton({
                number: 4
            })
        ];
        const hotcuePage2 = Array(8).fill({});
        const hotcuePage3 = Array(8).fill({});
        const samplerOrBeatloopRoolPage = Array(8).fill({});
        this.keyboard = Array(8).fill({});
        let i = 0;
        /* eslint no-unused-vars: "off" */
        for (const pad of hotcuePage2) {
            // start with hotcue 5; hotcues 1-4 are in defaultPadLayer
            hotcuePage2[i] = new HotcueButton({number: i + 1});
            hotcuePage3[i] = new HotcueButton({number: i + 13});
            if (UseBeatloopRoolInsteadOfSampler) {
                samplerOrBeatloopRoolPage[i] = new BeatLoopRollButton({
                    number: i,
                    deck: this,
                });

            } else {
                let samplerNumber = i + 1;
                if (samplerNumber > 4) {
                    samplerNumber += 4;
                }
                if (decks[0] > 1) {
                    samplerNumber += 4;
                }
                samplerOrBeatloopRoolPage[i] = new SamplerButton({
                    number: samplerNumber,
                });
                if (SamplerCrossfaderAssign) {
                    engine.setValue(
                        "[Sampler" + samplerNumber + "]",
                        "orientation",
                        (decks[0] === 1) ? 0 : 2
                    );
                }
            }
            this.keyboard[i] = new KeyboardButton({
                number: i + 1,
                deck: this,
            });
            i++;
        }

        const switchPadLayer = (deck, newLayer) => {
            let index = 0;
            for (let pad of deck.pads) {
                pad.outDisconnect();
                pad.inDisconnect();

                pad = newLayer[index];
                Object.assign(pad, io.pads[index]);
                if (!(pad instanceof HotcueButton)) {
                    pad.color = deck.color;
                }
                // don't change the group of SamplerButtons
                if (!(pad instanceof SamplerButton)) {
                    pad.group = deck.group;
                }
                if (pad.inPacket === undefined) {
                    pad.inPacket = inPackets[1];
                }
                pad.outPacket = outPacket;
                pad.inConnect();
                pad.outConnect();
                pad.outTrigger();
                deck.pads[index] = pad;
                index++;
            }
        };

        this.padLayers = {
            defaultLayer: 0,
            hotcuePage2: 1,
            hotcuePage3: 2,
            samplerPage: 3,
            keyboard: 5,
        };
        switchPadLayer(this, defaultPadLayer);
        this.currentPadLayer = this.padLayers.defaultLayer;

        this.hotcuePadModeButton = new Button({
            deck: this,
            onShortPress: function() {
                if (!this.shifted) {
                    if (this.deck.currentPadLayer !== this.deck.padLayers.hotcuePage2) {
                        switchPadLayer(this.deck, hotcuePage2);
                        this.deck.currentPadLayer = this.deck.padLayers.hotcuePage2;
                    } else {
                        switchPadLayer(this.deck, defaultPadLayer);
                        this.deck.currentPadLayer = this.deck.padLayers.defaultLayer;
                    }
                    this.deck.lightPadMode();
                } else {
                    switchPadLayer(this.deck, hotcuePage3);
                    this.deck.currentPadLayer = this.deck.padLayers.hotcuePage3;
                    this.deck.lightPadMode();
                }

            },
            // hack to switch the LED color when changing decks
            outTrigger: function() {
                this.deck.lightPadMode();
            }
        });
        // The record button doesn't have a mapping by default, but you can add yours here
        this.recordPadModeButton = new Button({
            onShortPress: function() {
                const runtimeData = engine.getRuntimeData();
                runtimeData.zoomedWaveform[this.group] = !runtimeData.zoomedWaveform[this.group];
                engine.setRuntimeData(runtimeData);
                this.output(runtimeData.zoomedWaveform[this.group]);
            }
        });
        this.samplesPadModeButton = new Button({
            deck: this,
            onShortPress: function() {
                if (this.deck.currentPadLayer !== this.deck.padLayers.samplerPage) {
                    switchPadLayer(this.deck, samplerOrBeatloopRoolPage);
                    engine.setValue("[Samplers]", "show_samplers", true);
                    this.deck.currentPadLayer = this.deck.padLayers.samplerPage;
                } else {
                    switchPadLayer(this.deck, defaultPadLayer);
                    engine.setValue("[Samplers]", "show_samplers", false);
                    this.deck.currentPadLayer = this.deck.padLayers.defaultLayer;
                }
                this.deck.lightPadMode();
            },
        });
        // The mute button doesn't have a mapping by default, but you can add yours here
        // this.mutePadModeButton = new Button({
        //    ...
        // });

        this.stemsPadModeButton = new Button({
            deck: this,
            previousMoveMode: null,
            onLongPress: function() {
                if (this.deck.keyboardPlayMode !== null) {
                    this.deck.keyboardPlayMode = null;
                    this.deck.lightPadMode();
                }
            },
            onShortPress: function() {
                if (this.previousMoveMode === null) {
                    this.previousMoveMode = this.deck.moveMode;
                    this.deck.moveMode = moveModes.keyboard;
                }
            },
            onShortRelease: function() {
                if (this.previousMoveMode !== null) {
                    this.deck.moveMode = this.previousMoveMode;
                    this.previousMoveMode = null;
                }
                if (this.deck.currentPadLayer === this.deck.padLayers.keyboard) {
                    switchPadLayer(this.deck, defaultPadLayer);
                    this.deck.currentPadLayer = this.deck.padLayers.defaultLayer;
                } else if (this.deck.currentPadLayer !== this.deck.padLayers.keyboard) {
                    switchPadLayer(this.deck, this.deck.keyboard);
                    this.deck.currentPadLayer = this.deck.padLayers.keyboard;
                }
                this.deck.lightPadMode();
            },
            onLongRelease: function() {
                if (this.previousMoveMode !== null && !this.deck.keyboardPlayMode) {
                    this.deck.moveMode = this.previousMoveMode;
                    this.previousMoveMode = null;
                }
            },
            // hack to switch the LED color when changing decks
            outTrigger: function() {
                this.deck.lightPadMode();
            }
        });

        this.wheelMode = wheelModes.vinyl;
        let motorWindDownTimer = 0;
        const motorWindDownTimerCallback = () => {
            engine.stopTimer(motorWindDownTimer);
            motorWindDownTimer = 0;
        };
        this.turntableButton = UseMotors ? new Button({
            deck: this,
            input: function(press) {
                if (press) {
                    this.deck.reverseButton.loopModeOff(true);
                    this.deck.fluxButton.loopModeOff(true);
                    if (this.deck.wheelMode === wheelModes.motor) {
                        this.deck.wheelMode = wheelModes.vinyl;
                        motorWindDownTimer = engine.beginTimer(MotorWindDownMilliseconds, motorWindDownTimerCallback, true);
                        engine.setValue(this.group, "scratch2_enable", false);
                    } else {
                        this.deck.wheelMode = wheelModes.motor;
                        const group = this.group;
                        engine.beginTimer(MotorWindUpMilliseconds, function() {
                            engine.setValue(group, "scratch2_enable", true);
                        }, true);
                    }
                    this.outTrigger();
                }
            },
            outTrigger: function() {
                const motorOn = this.deck.wheelMode === wheelModes.motor;
                this.send(this.color + (motorOn ? this.brightnessOn : this.brightnessOff));
                const vinylModeOn = this.deck.wheelMode === wheelModes.vinyl;
                this.deck.jogButton.send(this.color + (vinylModeOn ? this.brightnessOn : this.brightnessOff));
            },
        }) : undefined;
        this.jogButton = new Button({
            deck: this,
            input: function(press) {
                if (press) {
                    this.deck.reverseButton.loopModeOff(true);
                    this.deck.fluxButton.loopModeOff(true);
                    if (this.deck.wheelMode === wheelModes.vinyl) {
                        this.deck.wheelMode = wheelModes.jog;
                    } else {
                        if (this.deck.wheelMode === wheelModes.motor) {
                            motorWindDownTimer = engine.beginTimer(MotorWindDownMilliseconds, motorWindDownTimerCallback, true);
                        }
                        this.deck.wheelMode = wheelModes.vinyl;
                    }
                    engine.setValue(this.group, "scratch2_enable", false);
                    this.outTrigger();
                }
            },
            outTrigger: function() {
                const vinylOn = this.deck.wheelMode === wheelModes.vinyl;
                this.send(this.color + (vinylOn ? this.brightnessOn : this.brightnessOff));
                const motorOn = this.deck.wheelMode === wheelModes.motor;
                this.deck.turntableButton.send(this.color + (motorOn ? this.brightnessOn : this.brightnessOff));
            },
        });

        this.wheelTouch = new Button({
            touched: false,
            deck: this,
            input: function(touched) {
                this.touched = touched;
                if (this.deck.wheelMode === wheelModes.vinyl || this.deck.wheelMode === wheelModes.motor) {
                    if (touched) {
                        engine.setValue(this.group, "scratch2_enable", true);
                    } else {
                        this.stopScratchWhenOver();
                    }
                }
            },
            stopScratchWhenOver: function() {
                if (this.touched || this.deck.wheelMode === wheelModes.motor) {
                    return;
                }

                if (engine.getValue(this.group, "play") &&
                    engine.getValue(this.group, "scratch2") < 1.5 * baseRevolutionsPerSecond &&
                    engine.getValue(this.group, "scratch2") > 0) {
                    engine.setValue(this.group, "scratch2_enable", false);
                } else if (engine.getValue(this.group, "scratch2") === 0) {
                    engine.setValue(this.group, "scratch2_enable", false);
                } else {
                    engine.beginTimer(100, this.stopScratchWhenOver.bind(this), true);
                }
            }
        });

        // The relative and absolute position inputs have the same resolution but direction
        // cannot be determined reliably with the absolute position because it is easily
        // possible to spin the wheel fast enough that it spins more than half a revolution
        // between input packets. So there is no need to process the absolution position
        // at all; the relative position is sufficient.
        this.wheelRelative = new Component({
            oldValue: null,
            deck: this,
            // We use a rolling average on a sample of speed received. An alternative could
            // be to compute precise speed as soon as two points have been received. While the
            // alternative is likely going to reduce the delay. it may introduce imprefection due
            // to delays that could occurred at various level, so we stick with the naive average for now
            stack: [],
            stackIdx: 0,
            avgSpeed: 0,
            // There is a second sampling group, larger, that improve precision but increase delay, which
            // is used in TT mode
            stackAvg: [],
            stackAvgIdx: 0,
            ttAvgSpeed: 0,
            input: function(value) {
                const oldValue = this.oldValue;
                this.oldValue = value;
                if (oldValue === null) {
                    // This is to avoid the issue where the first time, we diff with 0, leading to the absolute value
                    return;
                }

                let diff = value - oldValue;

                if (diff > wheelRelativeMax / 2) {
                    diff = (wheelRelativeMax - value + oldValue) * -1;
                } else if (diff < -1 * (wheelRelativeMax / 2)) {
                    diff = wheelRelativeMax - oldValue + value;
                }

                this.stack[this.stackIdx] = diff / wheelTimerDelta;
                this.stackIdx = (this.stackIdx + 1) % WheelSpeedSample;

                this.avgSpeed = (this.stack.reduce((ps, v) => ps + v, 0) / this.stack.length) * wheelTicksPerTimerTicksToRevolutionsPerSecond;

                this.stackAvg[this.stackAvgIdx] = this.avgSpeed;
                this.stackAvgIdx = (this.stackAvgIdx + 1) % TurnTableSpeedSample;

                this.ttAvgSpeed = this.stackAvg.reduce((ps, v) => ps + v, 0) / this.stackAvg.length;

                if (this.avgSpeed === 0 &&
                    engine.getValue(this.group, "scratch2") === 0 &&
                    engine.getValue(this.group, "jog") === 0 &&
                    this.deck.wheelMode !== wheelModes.motor) {
                    return;
                }

                switch (this.deck.wheelMode) {
                case wheelModes.motor:
                    engine.setValue(this.group, "scratch2", this.ttAvgSpeed / baseRevolutionsPerSecond);
                    break;
                case wheelModes.loopIn:
                    {
                        const loopStartPosition = engine.getValue(this.group, "loop_start_position");
                        const loopEndPosition = engine.getValue(this.group, "loop_end_position");
                        const value = Math.min(loopStartPosition + (this.avgSpeed * LOOP_WHEEL_MOVE_FACTOR), loopEndPosition - LOOP_WHEEL_MOVE_FACTOR);
                        engine.setValue(
                            this.group,
                            "loop_start_position",
                            value
                        );
                    }
                    break;
                case wheelModes.loopOut:
                    {
                        const loopEndPosition = engine.getValue(this.group, "loop_end_position");
                        const value = loopEndPosition + (this.avgSpeed * LOOP_WHEEL_MOVE_FACTOR);
                        engine.setValue(
                            this.group,
                            "loop_end_position",
                            value
                        );
                    }
                    break;
                case wheelModes.vinyl:
                    if (this.deck.wheelTouch.touched || engine.getValue(this.group, "scratch2") !== 0) {
                        engine.setValue(this.group, "scratch2", this.avgSpeed);
                    } else {
                        engine.setValue(this.group, "jog", this.avgSpeed);
                    }
                    break;
                default:
                    engine.setValue(this.group, "jog", this.avgSpeed);
                }
            },
        });

        this.wheelLED = new Component({
            deck: this,
            outKey: "playposition",
            output: function(fractionOfTrack) {
                if (this.deck.wheelMode > wheelModes.motor) {
                    return;
                }
                const durationSeconds = engine.getValue(this.group, "duration");
                const positionSeconds = fractionOfTrack * durationSeconds;
                const revolutions = positionSeconds * baseRevolutionsPerSecond;
                const fractionalRevolution = revolutions - Math.floor(revolutions);
                const LEDposition = fractionalRevolution * wheelAbsoluteMax;

                const wheelOutput = Array(40).fill(0);
                wheelOutput[0] = decks[0] - 1;
                wheelOutput[1] = wheelLEDmodes.spot;
                wheelOutput[2] = LEDposition & 0xff;
                wheelOutput[3] = LEDposition >> 8;
                wheelOutput[4] = this.color + Button.prototype.brightnessOn;

                controller.send(wheelOutput, null, 50, true);

            }
        });

        for (const property in this) {
            if (Object.prototype.hasOwnProperty.call(this, property)) {
                const component = this[property];
                if (component instanceof Component) {
                    Object.assign(component, io[property]);
                    if (component.inPacket === undefined) {
                        component.inPacket = inPackets[1];
                    }
                    component.outPacket = outPacket;
                    if (component.group === undefined) {
                        component.group = this.group;
                    }
                    if (component.color === undefined) {
                        component.color = this.color;
                    }
                    if (component instanceof Encoder) {
                        component.max = 2 ** component.inBitLength - 1;
                    }
                    component.inConnect();
                    component.outConnect();
                    component.outTrigger();
                    if (this.unshift !== undefined && typeof this.unshift === "function") {
                        this.unshift();
                    }
                }
            }
        }
    }

    assignKeyboardPlayMode(group, action) {
        this.keyboardPlayMode = {
            group: group,
            action: action,
        };
        this.lightPadMode();
    }

    lightPadMode() {
        if (this.currentPadLayer === this.padLayers.hotcuePage2) {
            this.hotcuePadModeButton.send(this.hotcuePadModeButton.color + this.hotcuePadModeButton.brightnessOn);
        } else if (this.currentPadLayer === this.padLayers.hotcuePage3) {
            this.hotcuePadModeButton.send(LedColors.white + this.hotcuePadModeButton.brightnessOn);
        } else {
            this.hotcuePadModeButton.send(this.hotcuePadModeButton.color + this.hotcuePadModeButton.brightnessOff);
        }

        // unfortunately the other pad mode buttons only have one LED color
        // const recordPadModeLEDOn = this.currentPadLayer === this.padLayers.hotcuePage3;
        // this.recordPadModeButton.send(recordPadModeLEDOn ? 127 : 0);

        const samplesPadModeLEDOn = this.currentPadLayer === this.padLayers.samplerPage;
        this.samplesPadModeButton.send(samplesPadModeLEDOn ? 127 : 0);

        // this.mutePadModeButtonLEDOn = this.currentPadLayer === this.padLayers.samplerPage2;
        // const mutedModeButton.send(mutePadModeButtonLEDOn ? 127 : 0);

        const runtimeData = engine.getRuntimeData();
        if (this.keyboardPlayMode !== null) {
            if (runtimeData.keyboardMode) {
                runtimeData.keyboardMode[this.group] = true;
            }
            this.stemsPadModeButton.send(LedColors.green + this.stemsPadModeButton.brightnessOn);
        } else {
            const keyboardPadModeLEDOn = this.currentPadLayer === this.padLayers.keyboard;
            if (runtimeData.keyboardMode) {
                runtimeData.keyboardMode[this.group] = keyboardPadModeLEDOn;
            }
            this.stemsPadModeButton.send(this.stemsPadModeButton.color + (keyboardPadModeLEDOn ? this.stemsPadModeButton.brightnessOn : this.stemsPadModeButton.brightnessOff));
        }
        engine.setRuntimeData(runtimeData);
    }
}

class S4Mk3MixerColumn extends ComponentContainer {
    constructor(group, inPackets, outPacket, io) {
        super();

        this.group = group;

        this.gain = new Pot({
            inKey: "pregain",
        });
        this.eqHigh = new Pot({
            group: "[EqualizerRack1_" + group + "_Effect1]",
            inKey: "parameter3",
        });
        this.eqMid = new Pot({
            group: "[EqualizerRack1_" + group + "_Effect1]",
            inKey: "parameter2",
        });
        this.eqLow = new Pot({
            group: "[EqualizerRack1_" + group + "_Effect1]",
            inKey: "parameter1",
        });
        this.quickEffectKnob = new Pot({
            group: "[QuickEffectRack1_" + group + "]",
            inKey: "super1",
        });
        this.volume = new Pot({
            inKey: "volume",
        });

        this.pfl = new ToggleButton({
            inKey: "pfl",
            outKey: "pfl",
        });

        this.effectUnit1Assign = new PowerWindowButton({
            group: "[EffectRack1_EffectUnit1]",
            key: "group_" + this.group + "_enable",
        });

        this.effectUnit2Assign = new PowerWindowButton({
            group: "[EffectRack1_EffectUnit2]",
            key: "group_" + this.group + "_enable",
        });

        // FIXME: Why is output not working for these?
        this.saveGain = new PushButton({
            key: "update_replaygain_from_pregain"
        });

        this.crossfaderSwitch = new Component({
            inBitLength: 2,
            input: function(value) {
                if (value === 0) {
                    engine.setValue(this.group, "orientation", 2);
                } else if (value === 1) {
                    engine.setValue(this.group, "orientation", 1);
                } else if (value === 2) {
                    engine.setValue(this.group, "orientation", 0);
                }
            },
        });

        for (const property in this) {
            if (Object.prototype.hasOwnProperty.call(this, property)) {
                const component = this[property];
                if (component instanceof Component) {
                    Object.assign(component, io[property]);
                    if (component instanceof Pot) {
                        component.inPacket = inPackets[2];
                    } else {
                        component.inPacket = inPackets[1];
                    }
                    component.outPacket = outPacket;

                    if (component.group === undefined) {
                        component.group = this.group;
                    }

                    component.inConnect();
                    component.outConnect();
                    component.outTrigger();
                }
            }
        }
    }
}

const packetToBinaryString = (data) => {
    let string = "";
    for (const byte of data) {
        if (byte === 0) {
            // special case because Math.log(0) === Infinity
            string = string + "0".repeat(8) + ",";
        } else {
            const numOfZeroes = 7 - Math.floor(Math.log(byte) / Math.log(2));
            string = string + "0".repeat(numOfZeroes) + byte.toString(2) + ",";
        }
    }
    // remove trailing comma
    return string.slice(0, -1);
};

class S4MK3 {
    constructor() {
        if (engine.getValue("[Master]", "num_samplers") < 16) {
            engine.setValue("[Master]", "num_samplers", 16);
        }

        this.inPackets = [];
        this.inPackets[1] = new HIDInputPacket(1);
        this.inPackets[2] = new HIDInputPacket(2);
        this.inPackets[3] = new HIDInputPacket(3);

        // There are various of other HID report which doesn't seem to have any
        // immediate use but it is likely that some useful settings may be found
        // in them such as the wheel tension.

        this.outPackets = [];
        this.outPackets[128] = new HIDOutputPacket(128, 94);

        this.effectUnit1 = new S4Mk3EffectUnit(1, this.inPackets, this.outPackets[128],
            {
                mixKnob: {inByte: 31},
                mainButton: {inByte: 2, inBit: 6, outByte: 62},
                knobs: [
                    {inByte: 33},
                    {inByte: 35},
                    {inByte: 37},
                ],
                buttons: [
                    {inByte: 2, inBit: 7, outByte: 63},
                    {inByte: 2, inBit: 3, outByte: 64},
                    {inByte: 2, inBit: 2, outByte: 65},
                ],
            }
        );
        this.effectUnit2 = new S4Mk3EffectUnit(2, this.inPackets, this.outPackets[128],
            {
                mixKnob: {inByte: 71},
                mainButton: {inByte: 10, inBit: 4, outByte: 73},
                knobs: [
                    {inByte: 73},
                    {inByte: 75},
                    {inByte: 77},
                ],
                buttons: [
                    {inByte: 10, inBit: 5, outByte: 74},
                    {inByte: 10, inBit: 6, outByte: 75},
                    {inByte: 10, inBit: 7, outByte: 76},
                ],
            }
        );

        // There is no consistent offset between the left and right deck,
        // so every single components' IO needs to be specified individually
        // for both decks.
        this.leftDeck = new S4Mk3Deck(
            [1, 3], [DeckColors[0], DeckColors[2]], 0, this.effectUnit1,
            this.inPackets, this.outPackets[128],
            {
                playButton: {inByte: 5, inBit: 0, outByte: 55},
                cueButton: {inByte: 5, inBit: 1, outByte: 8},
                syncButton: {inByte: 6, inBit: 7, outByte: 14},
                syncMasterButton: {inByte: 1, inBit: 0, outByte: 15},
                hotcuePadModeButton: {inByte: 5, inBit: 2, outByte: 9},
                recordPadModeButton: {inByte: 5, inBit: 3, outByte: 56},
                samplesPadModeButton: {inByte: 5, inBit: 4, outByte: 57},
                mutePadModeButton: {inByte: 5, inBit: 5, outByte: 58},
                stemsPadModeButton: {inByte: 6, inBit: 0, outByte: 10},
                deckButtonLeft: {inByte: 6, inBit: 2},
                deckButtonRight: {inByte: 6, inBit: 3},
                deckButtonOutputByteOffset: 12,
                tempoFaderLED: {outByte: 11},
                shiftButton: {inByte: 6, inBit: 1, outByte: 59},
                leftEncoder: {inByte: 20, inBit: 0},
                leftEncoderPress: {inByte: 7, inBit: 2},
                rightEncoder: {inByte: 20, inBit: 4},
                rightEncoderPress: {inByte: 7, inBit: 5},
                libraryEncoder: {inByte: 21, inBit: 0},
                libraryEncoderPress: {inByte: 1, inBit: 1},
                turntableButton: {inByte: 6, inBit: 5, outByte: 17},
                jogButton: {inByte: 6, inBit: 4, outByte: 16},
                gridButton: {inByte: 6, inBit: 6, outByte: 18},
                reverseButton: {inByte: 2, inBit: 4, outByte: 60},
                fluxButton: {inByte: 2, inBit: 5, outByte: 61},
                libraryPlayButton: {inByte: 1, inBit: 5, outByte: 22},
                libraryStarButton: {inByte: 1, inBit: 4, outByte: 21},
                libraryPlaylistButton: {inByte: 2, inBit: 1, outByte: 20},
                libraryViewButton: {inByte: 2, inBit: 0, outByte: 19},
                pads: [
                    {inByte: 4, inBit: 5, outByte: 0},
                    {inByte: 4, inBit: 4, outByte: 1},
                    {inByte: 4, inBit: 7, outByte: 2},
                    {inByte: 4, inBit: 6, outByte: 3},

                    {inByte: 4, inBit: 3, outByte: 4},
                    {inByte: 4, inBit: 2, outByte: 5},
                    {inByte: 4, inBit: 1, outByte: 6},
                    {inByte: 4, inBit: 0, outByte: 7},
                ],
                tempoFader: {inByte: 13, inBit: 0, inBitLength: 16, inPacket: this.inPackets[2]},
                wheelRelative: {inByte: 12, inBit: 0, inBitLength: 16, inPacket: this.inPackets[3]},
                wheelAbsolute: {inByte: 16, inBit: 0, inBitLength: 16, inPacket: this.inPackets[3]},
                wheelTouch: {inByte: 17, inBit: 4},
            }
        );

        this.rightDeck = new S4Mk3Deck(
            [2, 4], [DeckColors[1], DeckColors[3]], 1, this.effectUnit2,
            this.inPackets, this.outPackets[128],
            {
                playButton: {inByte: 13, inBit: 0, outByte: 66},
                cueButton: {inByte: 15, inBit: 5, outByte: 31},
                syncButton: {inByte: 15, inBit: 4, outByte: 37},
                syncMasterButton: {inByte: 11, inBit: 0, outByte: 38},
                hotcuePadModeButton: {inByte: 13, inBit: 2, outByte: 32},
                recordPadModeButton: {inByte: 13, inBit: 3, outByte: 67},
                samplesPadModeButton: {inByte: 13, inBit: 4, outByte: 68},
                mutePadModeButton: {inByte: 13, inBit: 5, outByte: 69},
                stemsPadModeButton: {inByte: 13, inBit: 1, outByte: 33},
                deckButtonLeft: {inByte: 15, inBit: 2},
                deckButtonRight: {inByte: 15, inBit: 3},
                deckButtonOutputByteOffset: 35,
                tempoFaderLED: {outByte: 34},
                shiftButton: {inByte: 15, inBit: 1, outByte: 70},
                leftEncoder: {inByte: 21, inBit: 4},
                leftEncoderPress: {inByte: 16, inBit: 5},
                rightEncoder: {inByte: 22, inBit: 0},
                rightEncoderPress: {inByte: 16, inBit: 2},
                libraryEncoder: {inByte: 22, inBit: 4},
                libraryEncoderPress: {inByte: 11, inBit: 1},
                turntableButton: {inByte: 15, inBit: 6, outByte: 40},
                jogButton: {inByte: 15, inBit: 0, outByte: 39},
                gridButton: {inByte: 15, inBit: 7, outByte: 41},
                reverseButton: {inByte: 11, inBit: 4, outByte: 71},
                fluxButton: {inByte: 11, inBit: 5, outByte: 72},
                libraryPlayButton: {inByte: 10, inBit: 2, outByte: 45},
                libraryStarButton: {inByte: 10, inBit: 1, outByte: 44},
                libraryPlaylistButton: {inByte: 10, inBit: 3, outByte: 43},
                libraryViewButton: {inByte: 10, inBit: 0, outByte: 42},
                pads: [
                    {inByte: 14, inBit: 5, outByte: 23},
                    {inByte: 14, inBit: 4, outByte: 24},
                    {inByte: 14, inBit: 7, outByte: 25},
                    {inByte: 14, inBit: 6, outByte: 26},

                    {inByte: 14, inBit: 3, outByte: 27},
                    {inByte: 14, inBit: 2, outByte: 28},
                    {inByte: 14, inBit: 1, outByte: 29},
                    {inByte: 14, inBit: 0, outByte: 30},
                ],
                tempoFader: {inByte: 11, inBit: 0, inBitLength: 16, inPacket: this.inPackets[2]},
                wheelRelative: {inByte: 40, inBit: 0, inBitLength: 16, inPacket: this.inPackets[3]},
                wheelAbsolute: {inByte: 44, inBit: 0, inBitLength: 16, inPacket: this.inPackets[3]},
                wheelTouch: {inByte: 17, inBit: 5},
            }
        );

        // The interaction between the FX SELECT buttons and the QuickEffect enable buttons is rather complex.
        // It is easier to have this separate from the S4Mk3MixerColumn class and the FX SELECT buttons are not
        // really in the mixer columns.
        this.mixer = new Mixer(this.inPackets, this.outPackets);

        /* eslint no-unused-vars: "off" */
        // const meterConnection = engine.makeConnection("[Master]", "guiTick50ms", function(_value) {
        //     const deckMeters = Array(78).fill(0);
        //     // Each column has 14 segments, but treat the top one specially for the clip indicator.
        //     const deckSegments = 13;
        //     for (let deckNum = 1; deckNum <= 4; deckNum++) {
        //         const deckGroup = "[Channel" + deckNum + "]";
        //         const deckLevel = engine.getValue(deckGroup, "VuMeter");
        //         const columnBaseIndex = (deckNum - 1) * (deckSegments + 2);
        //         const scaledLevel = deckLevel * deckSegments;
        //         const segmentsToLightFully = Math.floor(scaledLevel);
        //         const partialSegmentValue = scaledLevel - segmentsToLightFully;
        //         if (segmentsToLightFully > 0) {
        //             // There are 3 brightness levels per segment: off, dim, and full.
        //             for (let i = 0; i <= segmentsToLightFully; i++) {
        //                 deckMeters[columnBaseIndex + i] = 127;
        //             }
        //             if (partialSegmentValue > 0.5 && segmentsToLightFully < deckSegments) {
        //                 deckMeters[columnBaseIndex + segmentsToLightFully + 1] = 125;
        //             }
        //         }
        //         if (engine.getValue(deckGroup, "PeakIndicator")) {
        //             deckMeters[columnBaseIndex + deckSegments + 1] = 127;
        //         }
        //     }
        //     // There are more bytes in the packet which seem like they should be for the main
        //     // mix meters, but setting those bytes does not do anything, except for lighting
        //     // the clip lights on the main mix meters.
        //     controller.send(deckMeters, null, 129);
        // });
        if (UseMotors) {
            engine.beginTimer(20, this.motorCallback.bind(this));
            this.leftVelocityFactor = wheelAbsoluteMax * baseRevolutionsPerSecond * 2;
            this.rightVelocityFactor = wheelAbsoluteMax * baseRevolutionsPerSecond * 2;

            this.leftFactor = [this.leftVelocityFactor];
            this.leftFactorIdx = 1;
            this.rightFactor = [this.rightVelocityFactor];
            this.rightFactorIdx = 1;

            this.averageLeftCorrectness = [];
            this.averageLeftCorrectnessIdx = 0;
            this.averageRightCorrectness = [];
            this.averageRightCorrectnessIdx = 0;
        }

    }
    motorCallback() {
        const motorData = [
            1, 0x20, 1, 0, 0,
            1, 0x20, 1, 0, 0,

        ];
        const maxVelocity = 10;

        let velocityLeft = 0;
        let velocityRight = 0;

        let expectedLeftSpeed = 0;
        let expectedRightSpeed = 0;

        if (this.leftDeck.wheelMode === wheelModes.motor
            && engine.getValue(this.leftDeck.group, "play")) {
            expectedLeftSpeed = engine.getValue(this.leftDeck.group, "rate_ratio");
        }

        if (this.rightDeck.wheelMode === wheelModes.motor
            && engine.getValue(this.rightDeck.group, "play")) {
            expectedRightSpeed = engine.getValue(this.rightDeck.group, "rate_ratio");
        }

        const currentLeftSpeed = this.leftDeck.wheelRelative.avgSpeed / baseRevolutionsPerSecond;
        const currentRightSpeed = this.rightDeck.wheelRelative.avgSpeed / baseRevolutionsPerSecond;

        if (expectedLeftSpeed) {
            velocityLeft = expectedLeftSpeed + Math.min(
                maxVelocity,
                Math.max(
                    -maxVelocity,
                    (expectedLeftSpeed - currentLeftSpeed)
                )
            );
        } else {
            if (TightnessFactor > 0.5) {
                // Super loose
                const reduceFactor = (Math.min(0.5, TightnessFactor - 0.5) / 0.5) * 0.7;
                velocityLeft = currentLeftSpeed * reduceFactor;
            } else if (TightnessFactor < 0.5) {
                // Super tight
                const reduceFactor = (2 - Math.max(0, TightnessFactor) * 4);
                velocityLeft = expectedLeftSpeed + Math.min(
                    maxVelocity,
                    Math.max(
                        -maxVelocity,
                        (expectedLeftSpeed - currentLeftSpeed) * reduceFactor
                    )
                );

            }
        }

        if (expectedRightSpeed) {
            velocityRight = expectedRightSpeed + Math.min(
                maxVelocity,
                Math.max(
                    -maxVelocity,
                    (expectedRightSpeed - currentRightSpeed)
                )
            );
        } else {
            if (TightnessFactor > 0.5) {
                // Super loose
                const reduceFactor = (Math.min(0.5, TightnessFactor - 0.5) / 0.5) * 0.7;
                velocityRight = currentRightSpeed * reduceFactor;
            } else if (TightnessFactor < 0.5) {
                // Super tight
                const reduceFactor = (2 - Math.max(0, TightnessFactor) * 4);
                console.log(reduceFactor);
                velocityRight = expectedRightSpeed + Math.min(
                    maxVelocity,
                    Math.max(
                        -maxVelocity,
                        (expectedRightSpeed - currentRightSpeed) * reduceFactor
                    )
                );

            }
        }

        if (velocityLeft < 0) {
            motorData[1] = 0xe0;
            motorData[2] = 0xfe;
            velocityLeft = -velocityLeft;
        }

        if (velocityRight < 0) {
            motorData[6] = 0xe0;
            motorData[7] = 0xfe;
            velocityRight = -velocityRight;
        }

        const roundedCurrentLeftSpeed = Math.round(currentLeftSpeed * 100);
        const roundedCurrentRightSpeed = Math.round(currentRightSpeed * 100);

        velocityLeft = velocityLeft * this.leftVelocityFactor;
        velocityRight = velocityRight * this.rightVelocityFactor;

        const minNormalFactor = 0.8 * wheelAbsoluteMax * baseRevolutionsPerSecond * 2;
        const maxNormalFactor = 1.2 * wheelAbsoluteMax * baseRevolutionsPerSecond * 2;

        if (velocityLeft > minNormalFactor && velocityLeft < maxNormalFactor) {
            this.averageLeftCorrectness[this.averageLeftCorrectnessIdx] = roundedCurrentLeftSpeed;
            this.averageLeftCorrectnessIdx = (this.averageLeftCorrectnessIdx + 1) % 10;
            const averageCorrectness = Math.round(this.averageLeftCorrectness.reduce((a, b) => a+b, 0) / this.averageLeftCorrectness.length);
            this.leftFactor[this.leftFactorIdx] = velocityLeft;
            this.leftFactorIdx = (this.leftFactorIdx + 1) % 10;
            const averageFactor = Math.round(this.leftFactor.reduce((a, b) => a+b, 0) / this.leftFactor.length);


            if ((averageCorrectness < 100 && velocityLeft > this.leftVelocityFactor) || (averageCorrectness > 100 && velocityLeft < this.leftVelocityFactor)) {
                this.leftVelocityFactor = averageFactor;
            }
        }

        if (velocityRight > minNormalFactor && velocityRight < maxNormalFactor) {
            this.averageRightCorrectness[this.averageRightCorrectnessIdx] = roundedCurrentRightSpeed / (expectedRightSpeed || 0.001);
            this.averageRightCorrectnessIdx = (this.averageRightCorrectnessIdx + 1) % 20;
            const averageCorrectness = Math.round(this.averageRightCorrectness.reduce((a, b) => a+b, 0) / this.averageRightCorrectness.length);
            this.rightFactor[this.rightFactorIdx] = velocityRight;
            this.rightFactorIdx = (this.rightFactorIdx + 1) % 20;
            const averageFactor = Math.round(this.rightFactor.reduce((a, b) => a+b, 0) / this.rightFactor.length);


            if ((averageCorrectness < 100 && velocityRight > this.rightVelocityFactor) || (averageCorrectness > 100 && velocityRight < this.rightVelocityFactor)) {
                this.rightVelocityFactor = averageFactor;
            }
        }

        if (velocityLeft) {
            velocityLeft += wheelAbsoluteMax / 2;
        }

        if (velocityRight) {
            velocityRight += wheelAbsoluteMax / 2;
        }

        velocityLeft = Math.min(
            MaxWheelForce,
            Math.floor(velocityLeft)
        );

        velocityRight = Math.min(
            MaxWheelForce,
            Math.floor(velocityRight)
        );

        motorData[3] = velocityLeft & 0xff;
        motorData[4] = velocityLeft >> 8;

        motorData[8] = velocityRight & 0xff;
        motorData[9] = velocityRight >> 8;
        controller.send(motorData, null, 49, true);
    }
    incomingData(data, _, forceReportId) {
        const reportId = forceReportId || data[0];
        if (reportId === 1) {
            this.inPackets[1].handleInput(data.buffer, !!forceReportId);
        } else if (reportId === 2) {
            this.inPackets[2].handleInput(data.buffer, !!forceReportId);
            // The master volume, booth volume, headphone mix, and headphone volume knobs
            // control the controller's audio interface in hardware, so they are not mapped.
        } else if (reportId === 3) {
            // The 32 bit unsigned ints at bytes 8 and 36 always have exactly the same value,
            // so only process one of them. This must be processed before the wheel positions.
            const oldWheelTimer = wheelTimer;
            const view = new DataView(data.buffer);
            wheelTimer = view.getUint32(8, true);
            // Processing first value; no previous value to compare with.
            if (oldWheelTimer === null) {
                return;
            }
            wheelTimerDelta = wheelTimer - oldWheelTimer;
            if (wheelTimerDelta < 0) {
                wheelTimerDelta += wheelTimerMax;
            }

            this.leftDeck.wheelRelative.input(view.getUint16(12, true));
            this.rightDeck.wheelRelative.input(view.getUint16(40, true));
        } else {
            console.warn("Unsupported HID repord with ID "+ reportId + ". Contains: "+data);
        }
    }
    init() {
        // sending these magic packets is required for the jog wheel LEDs to work
        const wheelLEDinitPacket = Array(26).fill(0);
        wheelLEDinitPacket[1] = 1;
        wheelLEDinitPacket[2] = 3;
        controller.send(wheelLEDinitPacket, null, 48, true);
        wheelLEDinitPacket[0] = 1;
        controller.send(wheelLEDinitPacket, null, 48);

        // Init wheel timer data
        wheelTimer = null;
        wheelTimerDelta = 0;

        // get state of knobs and faders
        this.incomingData(new Uint8Array(controller.getInputReport(1)), null, 1);
        this.incomingData(new Uint8Array(controller.getInputReport(2)), null, 2);


        const runtimeData = engine.getRuntimeData() || {};
        Object.assign(runtimeData, {
            keyboardMode: {
                "[Channel1]": false,
                "[Channel2]": false,
                "[Channel3]": false,
                "[Channel4]": false,
            },
            zoomedWaveform: {
                "[Channel1]": false,
                "[Channel2]": false,
                "[Channel3]": false,
                "[Channel4]": false,
            },
            group: [this.leftDeck.group, this.rightDeck.group],
            displayBeatloopSize: [false, false],
        });
        engine.setRuntimeData(runtimeData);
    }
    shutdown() {
        // button LEDs
        controller.send(new Array(94).fill(0), null, 128);

        // meter LEDs
        controller.send(new Array(78).fill(0), null, 129);

        const wheelOutput = Array(40).fill(0);
        // left wheel LEDs
        controller.send(wheelOutput, null, 50, true);
        // right wheel LEDs
        wheelOutput[0] = 1;
        controller.send(wheelOutput, null, 50, true);
    }
}

/* eslint no-unused-vars: "off", no-var: "off" */
var TraktorS4MK3 = new S4MK3();
