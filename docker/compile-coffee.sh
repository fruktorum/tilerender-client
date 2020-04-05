#!/bin/sh
cat assets/scripts/coffee/*.coffee | coffee -sc > assets/scripts/js/main.js
