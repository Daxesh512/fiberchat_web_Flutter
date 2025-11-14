// //*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:flutter/material.dart';

Map getTranslateNotificationStringsMap(BuildContext context) {
  Map map = {
    Dbkeys.notificationStringNewTextMessage: getTranslated(context, 'ntm'),
    Dbkeys.notificationStringNewImageMessage: getTranslated(context, 'nim'),
    Dbkeys.notificationStringNewVideoMessage: getTranslated(context, 'nvm'),
    Dbkeys.notificationStringNewAudioMessage: getTranslated(context, 'nam'),
    Dbkeys.notificationStringNewContactMessage: getTranslated(context, 'ncm'),
    Dbkeys.notificationStringNewDocumentMessage: getTranslated(context, 'ndm'),
    Dbkeys.notificationStringNewLocationMessage: getTranslated(context, 'nlm'),
    Dbkeys.notificationStringNewIncomingAudioCall:
        getTranslated(context, 'niac'),
    Dbkeys.notificationStringNewIncomingVideoCall:
        getTranslated(context, 'nivc'),
    Dbkeys.notificationStringCallEnded: getTranslated(context, 'ce'),
    Dbkeys.notificationStringMissedCall: getTranslated(context, 'mc'),
    Dbkeys.notificationStringAcceptOrRejectCall: getTranslated(context, 'aorc'),
    Dbkeys.notificationStringCallRejected: getTranslated(context, 'cr'),
  };
  return map;
}

const IsCallFeatureTotallyHide =
    false; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const Is24hrsTimeformat =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int GroupMemberslimit =
    500; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int BroadcastMemberslimit =
    500; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int StatusDeleteAfterInHours =
    24; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsLogoutButtonShowInSettingsPage =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const FeedbackEmail =
    ''; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingGroups =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingBroadcasts =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingStatus =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsPercentProgressShowWhileUploading =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxFileSizeAllowedInMB =
    60; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxNoOfFilesInMultiSharing =
    10; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxNoOfContactsSelectForForward =
    7; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.

//---- ####### Below Details Not neccsarily required unless you are using the Admin App:
const ConnectWithAdminApp =
    true; // If you are planning to use the admin app, set it to "true". We recommend it to always set it to true for Advance features whether you use the admin app or not.
const dynamic RateAppUrlWeb =
    null; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
// Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const TERMS_CONDITION_URL =
    'YOUR_TNC'; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const PRIVACY_POLICY_URL =
    'YOUR_PRIVACY_POLICY'; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
//--