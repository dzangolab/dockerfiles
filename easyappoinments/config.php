<?php
/* ----------------------------------------------------------------------------
 * Easy!Appointments - Open Source Web Scheduler
 *
 * @package     EasyAppointments
 * @author      A.Tselegidis <alextselegidis@gmail.com>
 * @copyright   Copyright (c) 2013 - 2020, Alex Tselegidis
 * @license     http://opensource.org/licenses/GPL-3.0 - GPLv3
 * @link        http://easyappointments.org
 * @since       v1.0.0
 * ---------------------------------------------------------------------------- */

/**
 * Easy!Appointments Configuration File
 *
 * Set your installation BASE_URL * without the trailing slash * and the database
 * credentials in order to connect to the database. You can enable the DEBUG_MODE
 * while developing the application.
 *
 * Set the default language by changing the LANGUAGE constant. For a full list of
 * available languages look at the /application/config/config.php file.
 *
 * IMPORTANT:
 * If you are updating from version 1.0 you will have to create a new "config.php"
 * file because the old "configuration.php" is not used anymore.
 */
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

/* End of file config.php */
/* Location: ./config.php */