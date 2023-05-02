import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/component/user_demo_mode_screen.dart';
import 'package:handyman_provider_flutter/auth/forgot_password_dialog.dart';
import 'package:handyman_provider_flutter/auth/sign_up_screen.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/selected_item_widget.dart';
import 'package:handyman_provider_flutter/handyman/handyman_dashboard_screen.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/login_response.dart';
import 'package:handyman_provider_flutter/models/register_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Text Field Controller
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  /// FocusNodes
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  bool isRemember = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isRemember = getBoolAsync(IS_REMEMBERED, defaultValue: true);
    if (isRemember) {
      emailCont.text = getStringAsync(USER_EMAIL);
      passwordCont.text = getStringAsync(USER_PASSWORD);
    }
  }

  //region Widgets
  Widget _buildTopWidget() {
    return Column(
      children: [

        Container(
          
          margin: EdgeInsets.fromLTRB(0, 58,0, 0),
          child: Image(
            
            image:AssetImage('assets/images/Sign_inScreen_topImage.png'),
            width: 142,
            height: 142,

          ),
        ),

        28.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hi', style: TextStyle(fontFamily:'trueno',color: Color(0xFF1C1F34),fontSize: 22,fontWeight: FontWeight.bold)).center(),
            4.width,
            Text('John!', style: TextStyle(fontFamily:'Work_Sans',color: primaryColor,fontSize: 22,fontWeight: FontWeight.bold)).center(),
          ],
        ),
        16.height,
        Text(
          context.translate.lblloginsubtitle,
          style: secondaryTextStyle(size: 16),
          textAlign: TextAlign.center,
        ).paddingSymmetric(horizontal: 32).center(),
       // 64.height,
      ],
    );
  }

  Widget _buildFormWidget() {
    return AutofillGroup(
      onDisposeAction: AutofillContextAction.commit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // align children to the center of the column

        children: [
          SizedBox(height: 31,),
          Container(
            height: 48,
            width: 326,
            child: AppTextField(

              textFieldType: TextFieldType.EMAIL,
              controller: emailCont,
              focus: emailFocus,
              nextFocus: passwordFocus,
              errorThisFieldRequired: context.translate.hintRequired,
              decoration: inputDecoration(context, hint: context.translate.hintEmailAddress,prefixIcon:  Icon(Icons.email, color: Colors.black,size: 20,), ),
              //suffix: ic_message.iconImage(size: 10).paddingAll(14),
              autoFillHints: [AutofillHints.email],
            ),
          ),
          24.height,
          Container(
            height: 48,
            width: 326,

            child: AppTextField(
              textFieldType: TextFieldType.PASSWORD,
              controller: passwordCont,
              focus: passwordFocus,
              errorThisFieldRequired: context.translate.hintRequired,
              suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
              suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
              errorMinimumPasswordLength: "${context.translate.errorPasswordLength} $passwordLengthGlobal",
              decoration: inputDecoration(context, hint: context.translate.hintPassword, prefixIcon: Image.asset('assets/icons/lock_ic.png',color: Colors.black,)),
              autoFillHints: [AutofillHints.password],
              onFieldSubmitted: (s) {
                loginUsers();
              },
            ),
          ),
         // 16.height,
        ],
      ),
    );
  }

  Widget _buildForgotRememberWidget() {
    return Container(
      width: 326,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  4.width,
                  SelectedItemWidget(isSelected: isRemember).onTap(() async {
                    await setValue(IS_REMEMBERED, isRemember);
                    isRemember = !isRemember;
                    setState(() {});
                  }),

                  TextButton(
                    onPressed: () async {
                      await setValue(IS_REMEMBERED, isRemember);
                      isRemember = !isRemember;
                      setState(() {});
                    },
                    child: Text(context.translate.rememberMe, style: TextStyle(color: Color(0xFF1F2224),fontFamily:'trueno' )),
                  ),
                ],
              ),
              TextButton(
                child: Text(
                  context.translate.forgotPassword,
                  style: TextStyle(
                      color: Color(0xFF009CEB),
                      fontStyle: FontStyle.normal,
                      fontSize: 12,
                      fontFamily: 'trueno'
                  ),

                ),
                onPressed: () {
                  showInDialog(
                    context,
                    contentPadding: EdgeInsets.zero,
                    dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
                    builder: (_) => ForgotPasswordScreen(),
                  );
                },
              ).flexible()
            ],
          ),
          89.height,
        ],
      ),
    );
  }

  Widget _buildButtonWidget() {
    return Column(
      children: [
        AppButton(
          text: (context.translate.lblLogin).toUpperCase(),
          elevation: 0,
          height: 40,
          color: primaryColor,
          textStyle: primaryTextStyle(color: white,fontFamily:'Work_Sans'),
          width: 326,
          onTap: () {
            loginUsers();
          },
        ),
        168.height,
        /*Text('Login With',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ), */


       /* Container(
          height:48 ,
          width: 326,
          child: AppButton(

            
            color: Color(0xFFF6FAFC),
            elevation: 0,

            onTap: (){},
            
            child: Row(
              
              children: <Widget>[
                
                Image.asset('assets/google_icon.png'),
                105.width,
                Text('Google',style: TextStyle(fontSize: 14,color: Colors.black),)
                
                
              ],
              
              
              
            ),

          ),
        ), */







        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.translate.doNotHaveAccount, style: secondaryTextStyle(fontFamily: 'trueno',color:Color(0xFF1F2224)       )),
            TextButton(
              onPressed: () {
                SignUpScreen().launch(context);
              },
              child: Text(
                context.translate.signUp,
                style: boldTextStyle(
                  color: primaryColor,
                  decoration: TextDecoration.underline,
                  fontStyle: FontStyle.normal,
                  fontFamily: 'trueno'
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  //endregion

  //region Methods
  void loginUsers() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      var request = {
        UserKeys.email: emailCont.text,
        UserKeys.password: passwordCont.text,
        UserKeys.playerId: getStringAsync(PLAYERID),
      };

      if (isRemember) {
        await setValue(USER_EMAIL, emailCont.text);
        await setValue(USER_PASSWORD, passwordCont.text);
        await setValue(IS_REMEMBERED, isRemember);
      }

      appStore.setLoading(true);

      await loginUser(request).then((res) async {
        /// Get Email User
        await authService.signInWithEmailPassword(email: res.data!.email.validate()).then((value) async {
          res.data!.uid = value.uid.validate();
          redirectWidget(res: res);
        }).catchError((e) {
          log(e.toString());

          if (e.toString().capitalizeFirstLetter() == USER_NOT_FOUND) {
            res.data!.password = passwordCont.text.trim();

            authService.signUpWithEmailPassword(userData: res.data!).then((value) {
              if (value) {
                redirectWidget(res: res);
              }
            }).catchError((e) {
              log(e.toString());
            });
          }
        });
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      });
      appStore.setLoading(false);
    }
  }

  void redirectWidget({required LoginResponse res}) async {
    TextInput.finishAutofillContext();

    if (res.data!.status.validate() == 1) {
      /// Saving Player ID to Firebase
      userService.updatePlayerIdInFirebase(email: res.data!.email.validate(), playerId: getStringAsync(PLAYERID)).catchError((e) {
        toast(e.toString());
      });

      /// Redirect on the base of User Role.
      appStore.setTester(res.data!.email == DEFAULT_PROVIDER_EMAIL || res.data!.email == DEFAULT_HANDYMAN_EMAIL);

      if (res.data!.userType.validate().trim() == USER_TYPE_PROVIDER) {
        /// if User type id Provider
        if (res.data != null) await saveUserData(res.data!);
        ProviderDashboardScreen(index: 0).launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      } else if (res.data!.userType.validate().trim() == USER_TYPE_HANDYMAN) {
        /// if User type id Handyman
        if (res.data != null) await saveUserData(res.data!);
        HandymanDashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      } else {
        toast(context.translate.cantLogin, print: true);
      }
    } else {
      appStore.setLoading(false);
      toast(context.translate.lblWaitForAcceptReq);
    }
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        elevation: 0,
        showBack: false,
        color: context.scaffoldBackgroundColor,
        systemUiOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: getStatusBrightness(val: appStore.isDarkMode), statusBarColor: context.scaffoldBackgroundColor),
      ),
      body: SizedBox(
        width: context.width(),
        child: Stack(
          children: [
            Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTopWidget(),
                    _buildFormWidget(),
                    _buildForgotRememberWidget(),
                    _buildButtonWidget(),
                    16.height,
                    if (isIqonicProduct)
                      UserDemoModeScreen(
                        onChanged: (email, password) {
                          if (email.isNotEmpty && password.isNotEmpty) {
                            emailCont.text = email;
                            passwordCont.text = password;
                          } else {
                            emailCont.clear();
                            passwordCont.clear();
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
            Observer(
              builder: (_) => LoaderWidget().center().visible(appStore.isLoading),
            ),
          ],
        ),
      ),
    );
  }
}
