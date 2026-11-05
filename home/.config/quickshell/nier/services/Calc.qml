pragma Singleton

import QtQuick
import Quickshell

// Arithmetic for the launcher, parsed by hand so typed text is never run as code.
Singleton {
    // Returns a number, or null when the text isn't a complete calculation.
    function evaluate(text) {
        const s = text.replace(/,/g, ".").replace(/\s+/g, "");
        if (!/^[0-9.+\-*\/%^()]+$/.test(s) || !/[0-9]/.test(s) || !/[+\-*\/%^(]/.test(s))
            return null;
        let i = 0;

        function fail() {
            throw new Error("bad expression");
        }
        function number() {
            const m = /^[0-9]*\.?[0-9]+|^[0-9]+\./.exec(s.slice(i));
            if (!m)
                fail();
            i += m[0].length;
            return parseFloat(m[0]);
        }
        function atom() {
            if (s[i] === "(") {
                i++;
                const v = sum();
                if (s[i] !== ")")
                    fail();
                i++;
                return v;
            }
            return number();
        }
        function power() {
            const base = atom();
            if (s[i] !== "^")
                return base;
            i++;
            return Math.pow(base, unary());
        }
        function unary() {
            if (s[i] === "-") {
                i++;
                return -unary();
            }
            if (s[i] === "+") {
                i++;
                return unary();
            }
            return power();
        }
        function product() {
            let v = unary();
            while (s[i] === "*" || s[i] === "/" || s[i] === "%") {
                const op = s[i++];
                const r = unary();
                v = op === "*" ? v * r : op === "/" ? v / r : v % r;
            }
            return v;
        }
        function sum() {
            let v = product();
            while (s[i] === "+" || s[i] === "-") {
                const op = s[i++];
                const r = product();
                v = op === "+" ? v + r : v - r;
            }
            return v;
        }
        try {
            const v = sum();
            return i === s.length && isFinite(v) ? Number(v.toPrecision(12)) : null;
        } catch (e) {
            return null;
        }
    }
}
