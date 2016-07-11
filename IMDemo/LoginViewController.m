//
//  LoginViewController.m
//  IMDemo
//
//  Created by Liwy on 16/7/10.
//  Copyright © 2016年 Liwy. All rights reserved.
//

#import "LoginViewController.h"

#import "RootViewController.h"

#import "EMSDK.h"

@interface LoginViewController ()

@property (nonatomic, strong) UITextField * userNameField;
@property (nonatomic, strong) UITextField * passwordField;
@property (nonatomic, strong) UIButton * loginButton;

- (void)loginButtonPressed:(UIButton *)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  [self.view addSubview:self.userNameField];
  [self.view addSubview:self.passwordField];
  [self.view addSubview:self.loginButton];
  
}

- (void)loginButtonPressed:(UIButton *)sender
{
  //登录
  
  EMError * error = [[EMClient sharedClient] loginWithUsername:self.userNameField.text password:self.passwordField.text];
  
  if (error == nil) {
    //登录成功
    //切换
    RootViewController * rootVC = [[RootViewController alloc] init];
    UINavigationController * navigation = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [[UIApplication sharedApplication].keyWindow setRootViewController:navigation];
  }
}

- (UIButton *)loginButton
{
  if (_loginButton == nil) {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setBounds:CGRectMake(0, 0, 80, 40)];
    [button setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), 300)];
    
    [button setTitle:@"登录" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _loginButton = button;
  }
  return _loginButton;
}

- (UITextField *)userNameField
{
  if (_userNameField == nil) {
    UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    textField.center = CGPointMake(CGRectGetMidX(self.view.bounds), 200);
    textField.borderStyle = UITextBorderStyleBezel;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.placeholder = @"用户名";
    
    _userNameField = textField;
  }
  return _userNameField;
}

- (UITextField *)passwordField
{
  if (_passwordField == nil) {
    UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    textField.center = CGPointMake(CGRectGetMidX(self.view.bounds), 250);
    textField.borderStyle = UITextBorderStyleBezel;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.placeholder = @"密码";

    _passwordField = textField;
  }
  return _passwordField;
}


@end
