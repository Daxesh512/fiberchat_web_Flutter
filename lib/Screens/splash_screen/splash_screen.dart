//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatelessWidget {
  final bool? isShowOnlySpinner;

  Splashscreen({this.isShowOnlySpinner = false});
  @override
  Widget build(BuildContext context) {
    return isShowSplashCustomAssetImage == true
        ? Scaffold(
            backgroundColor: splashBackgroundSolidColor,
            body: Center(
                child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.asset(
                  'assets/images/splash.jpg',
                  // width: double.infinity,
                  fit: BoxFit.fitHeight,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
                Positioned(
                  bottom: 40,
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: LinearProgressIndicator(
                          backgroundColor:
                              fiberchatPRIMARYcolor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              fiberchatSECONDARYolor.withOpacity(0.7)),
                        )),
                  ),
                )
              ],
            )),
          )
        : Scaffold(
            backgroundColor: splashBackgroundSolidColor,
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isWideScreen(MediaQuery.of(context).size.width)
                    ? Image.asset(
                        '$AppLogoPathDark',
                        // width: double.infinity,
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width / 4,
                      )
                    : Image.asset(
                        '$AppLogoPathDark',
                        // width: double.infinity,
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width / 1.3,
                      ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 10,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 5,
                    child: LinearProgressIndicator(
                      backgroundColor: fiberchatPRIMARYcolor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          fiberchatSECONDARYolor.withOpacity(0.7)),
                    ))
              ],
            )),
          );
  }
}
