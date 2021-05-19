<?php

class Config {

    // ------------------------------------------------------------------------
    // GENERAL SETTINGS
    // ------------------------------------------------------------------------

    const BASE_URL      = '__BASE_URL__';
    const LANGUAGE      = '__LANGUAGE__';
    const DEBUG_MODE    = __DEBUG_MODE__;

    // ------------------------------------------------------------------------
    // DATABASE SETTINGS
    // ------------------------------------------------------------------------

    const DB_HOST       = '__DB_HOST__';
    const DB_NAME       = '__DB_NAME__';
    const DB_USERNAME   = '__DB_USERNAME__';
    const DB_PASSWORD   = '__DB_PASSWORD__';

    // ------------------------------------------------------------------------
    // GOOGLE CALENDAR SYNC
    // ------------------------------------------------------------------------

    const GOOGLE_SYNC_FEATURE   = __GOOGLE_SYNC_FEATURE__; // Enter TRUE or FALSE
    const GOOGLE_PRODUCT_NAME   = '__GOOGLE_PRODUCT_NAME__';
    const GOOGLE_CLIENT_ID      = '__GOOGLE_CLIENT_ID__';
    const GOOGLE_CLIENT_SECRET  = '__GOOGLE_CLIENT_SECRET__';
    const GOOGLE_API_KEY        = '__GOOGLE_API_KEY__';
}
