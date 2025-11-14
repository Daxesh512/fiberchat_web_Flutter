//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:flutter/material.dart';

const Color colorCallbuttons = Color(0xff448AFF);
// applied to call buttons in Video Call & Audio Call .dart pages

const bool deleteMessaqgeForEveryoneDeleteFromServer = true;
//in group chat if delete message for everyone is tapped, It will be the message tile will be deleted from server (if this switch is true) OR if this switch is false, it will show the deleted messase as "Message is deleted"

const int ImageQualityCompress = 50;
// This is compress the chat image size in percent while uploading to firesbase storage
const int DpImageQualityCompress = 34;
// This is compress the user display picture  size in percent while uploading to firesbase storage

const bool IsVideoQualityCompress = true;
// This is compress the video size  to medium quality while uploading to firesbase storage

int maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading = 25;
//Minimum Value should be 15.
const int timeOutSeconds = 50;
// Default phone Auth Code auto retrival timeout
const IsShowNativeTimDate = true;
// Show Date Time in the user selected langauge
const IsShowDeleteChatOption = true;
// Show Delete Chat Button in the All Chats Screens.

const IsRemovePhoneNumberFromCallingPageWhenOnCall = false;
//## under development yet
const OnlyPeerWhoAreSavedInmyContactCanMessageOrCallMe = false;
//If this is true, then only contacts saved in my device can send a message or call me.
const DEFAULT_LANGUAGE_FILE_CODE = 'en';
//default language code if file is present is localization folder example-> en.json
const IsShowLanguageNameInNativeLanguage = false;
// if "true", users can see the language name in respective language
const IsAdaptiveWidthTab = false;
//Automatically adapt the Tab size in tab bar homepage as per the content length. Set it to "true" if your default language code is any of these ["pt", "nl", "vi", "tr", "id", "fr", "es", "ka"]
const IsShowGIFsenderButtonByGIPHY = true;
//If true, GIF sending button will be shown to users in the text input area in chatrooms.

// final loginPageTopColor = fiberchatWhite;

// final loginPageBottomColor = fiberchatWhite;

final textInSendButton = "";
// If any text is placed here, it will be visible in the send button of text messsages in the Chat room , by default paper_plane icon is here.

const AgoraVideoResultionWIDTH = 1920;
//Agora Video Call Resolution, see details - https://docs.agora.io/en/video-calling/develop/ensure-channel-quality?platform=web

const AgoraVideoResultionHEIGHT = 1080;
