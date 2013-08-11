//
//  VueChat.m
//  Portail Mines
//
//  Created by Valérian Roche on 24/01/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "VueChat.h"
#import "Reseau.h"
#import "Trombi.h"
#import "ConversionChat.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
@interface VueChat () {
}

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UITextField *barreMessage;
@property (nonatomic, strong) Reseau *reseau;
@property (nonatomic, strong) NSDictionary *contenuChat;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int periodeRaffraichissement;
@property (nonatomic, strong) NSMutableAttributedString *messages;
@property (nonatomic) BOOL scrollAuto;
@property (nonatomic) BOOL attenteReponse;
@property (nonatomic) BOOL connexionFonctionnelle;
@property (nonatomic) BOOL visible;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSDictionary *dico;

@property (nonatomic, strong) IBOutlet UITextView *vue;
@property (nonatomic, strong) ConversionChat *conversion;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *detectTapVue;
@property (nonatomic, strong) NSRegularExpression *regexIdent;

@end

@implementation VueChat
@synthesize reseau = _reseau, toolBar = _toolBar, messages = _messages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andReseau:(Reseau *)reseau
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.reseau = reseau;
        self.title = NSLocalizedString(@"Chat", @"Chat");
        self.tabBarItem.title = @"Chat";
        self.tabBarItem.image = [UIImage imageNamed:@"chat.png"];
        self.dico = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"bell-ringing-05",@"water-droplet-1",@"zippo-close-1", nil] forKeys:[NSArray arrayWithObjects:@"Son de cloches",@"Goutte d'eau", @"Briquet", nil]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    int hauteurBarre = self.toolBar.bounds.size.height;
    [self.vue setFrame:CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.height - hauteurBarre)];
    [self.toolBar setFrame:CGRectMake(0, self.view.bounds.size.height - hauteurBarre, self.view.bounds.size.width,hauteurBarre)];
    [self.view addSubview:self.toolBar];
    [self.barreMessage setBorderStyle:UITextBorderStyleRoundedRect];
    [self.vue setTextAlignment:NSTextAlignmentCenter];
    [self.vue setDelegate:self];
    
    if ([self.vue respondsToSelector:@selector(setAttributedString:)])
        [self.vue setAttributedText:[[NSAttributedString alloc] initWithString:@"Rien à afficher pour l'instant..." attributes:[NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]] forKey:NSFontAttributeName]]];
    else {
        [self.vue setText:@"Rien à afficher pour l'instant..."];
    }
    [self.vue setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [self.detectTapVue addTarget:self.barreMessage action:@selector(resignFirstResponder)];
    [self.detectTapVue setEnabled:NO];
    UIBarButtonItem *bouttonChoix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(choixScroll:)];
    [self.navigationItem setRightBarButtonItem:bouttonChoix];
    self.scrollAuto = YES;
    
    [self.barreMessage setDelegate:self];
    
    [self addObserver:self forKeyPath:@"self.connexionFonctionnelle" options:0 context:0];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.connexionFonctionnelle = NO;
    self.visible = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majChat:) name:@"MajChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(affichageClavier:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(affichageClavier:) name:UIKeyboardWillHideNotification object:nil];
    self.periodeRaffraichissement = [[NSUserDefaults standardUserDefaults] integerForKey:@"tempsRaffraichissement"];
    
    [self.reseau getChat];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.periodeRaffraichissement target:self.reseau selector:@selector(getChat) userInfo:nil repeats:YES];
 
    self.player = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.connexionFonctionnelle) {
        self.navigationItem.title = @"Chat ✓";
    }
    else
        self.navigationItem.title = @"Chat ✕";
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.connexionFonctionnelle = NO;
    self.visible = NO;
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MajChat" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EnvoieValide" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)majChat:(NSNotification *)notif {
    if ([[notif name] isEqualToString:@"EnvoieValide"]) {
        self.attenteReponse = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EnvoieValide" object:nil];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.periodeRaffraichissement target:self.reseau selector:@selector(getChat) userInfo:nil repeats:YES];
    }
    
    if ([[[notif userInfo] objectForKey:@"succes"] boolValue]) {
        // Code dans le cas où la maj a fonctionné
        self.connexionFonctionnelle = YES;
        
        if ([[notif name] isEqualToString:@"EnvoieValide"])
            [self.barreMessage setText:@""];
        
        NSTimeInterval heure;
        if ([[[notif userInfo] objectForKey:@"maj"] boolValue]) {
            
            if (![[notif name] isEqualToString:@"EnvoieValide"]) {
                if (self.visible && self.contenuChat) {
                    [self.player play];
                }
            }
            // Mettre à jour
            self.contenuChat = [self.reseau messagesChat];
            heure = [[self.contenuChat objectForKey:@"time"] doubleValue];
            
            [self majMessages];
        }
        else {
            // On ne change que le temps
            heure = [[[notif userInfo] objectForKey:@"temps"] doubleValue];
        }
    }
    else {
        self.connexionFonctionnelle = NO;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.periodeRaffraichissement target:self.reseau selector:@selector(getChat) userInfo:nil repeats:YES];
    }
}

-(void)majMessages {
    self.contenuChat = [self.reseau messagesChat];
    for (NSDictionary *chaines in [self.contenuChat objectForKey:@"messages"]) {
        [self.messages appendAttributedString:[self.conversion conversionMessage:[chaines objectForKey:@"text"]]];
        if ([self.vue respondsToSelector:@selector(setAttributedText:)])
            [self.vue setAttributedText:self.messages];
        else
            [self.vue setText:[self.messages string]];
        [[self.messages mutableString] appendString:@"\r\n"];
    }
    if ([self scrollAuto])
        [self.vue scrollRangeToVisible:NSMakeRange(self.vue.text.length, 1)];
}

// Getters

-(NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"dd-MM - HH:mm:ss"];
    }
    return _dateFormatter;
}

-(NSMutableAttributedString *)messages {
    if (!_messages) {
        [self.vue setTextAlignment:NSTextAlignmentNatural];
        _messages = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    return _messages;
}

-(AVAudioPlayer *)player {
    if (!_player) {
        NSString *nomSon = [self.dico objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"SonnerieChat"]];
        if (nomSon) {
            NSURL *url = [[NSBundle mainBundle] URLForResource:nomSon withExtension:@"mp3"];
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        }
    }
    return _player;
}

-(ConversionChat *)conversion {
    if (!_conversion) _conversion = [[ConversionChat alloc] init];
    return _conversion;
}

-(NSRegularExpression *)regexIdent {
    if (!_regexIdent) _regexIdent = [[NSRegularExpression alloc] initWithPattern:@"(\\d{2}\\p{L}{1,6})" options:NSRegularExpressionCaseInsensitive error:nil];
    return _regexIdent;
}

-(void)changement:(NSString *)username {
    Trombi *trombi = nil;
    for (UINavigationController *controller in self.tabBarController.viewControllers) {
        if ([[controller viewControllers] count] &&[[[controller viewControllers] objectAtIndex:0] isKindOfClass:[Trombi class]])
            trombi = [[controller viewControllers] objectAtIndex:0];
    }
    
    if ([trombi affichagePersonne:username]) {
        UIView *current = self.view;
        UIView *new = [[trombi.navigationController topViewController] view];
        [UIView transitionFromView:current
                            toView:new
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCurlUp | UIViewAnimationOptionCurveEaseOut
                        completion:^(BOOL finished){
                            if (finished)
                                [self.tabBarController setSelectedViewController:trombi.navigationController];
                        }];
    }
}

-(IBAction)choixScroll:(UIBarButtonItem *)sender {
    self.scrollAuto = !self.scrollAuto;
    
    UIBarButtonItem *boutton;
    if (!self.scrollAuto) {
        boutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(choixScroll:)];
    }
    else {
        boutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(choixScroll:)];
        
        [self.vue scrollRangeToVisible:NSMakeRange(self.vue.text.length, 1)];
    }
    [self.navigationItem setRightBarButtonItem:boutton];
}

// Gestion de la barre

-(void)affichageClavier:(NSNotification *)notif {
    if ([[notif name] isEqualToString:UIKeyboardWillShowNotification]) {
        [UIView animateWithDuration:[[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^(void) {
            CGRect ancienRect = self.toolBar.frame;
            //CGRect rect = [self.view convertRect:[((NSValue *) [[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]) CGRectValue] fromView:self.view];
            CGFloat hauteur;
            if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                hauteur = [((NSValue *) [[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]) CGRectValue].size.height;
            }
            else
                hauteur = [((NSValue *) [[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey]) CGRectValue].size.width;
            [self.toolBar setFrame:CGRectOffset(ancienRect,0,-hauteur+self.tabBarController.tabBar.bounds.size.height)];
            [self.vue setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-hauteur+self.tabBarController.tabBar.bounds.size.height-ancienRect.size.height)];
        }];
        [self.vue scrollRangeToVisible:NSMakeRange(self.vue.text.length, 1)];
        [self.detectTapVue setEnabled:YES];
    }
    else {
        [UIView animateWithDuration:[[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^(void) {
            CGFloat hauteur = self.toolBar.bounds.size.height;
            [self.toolBar setFrame:CGRectMake(0, self.view.bounds.size.height - hauteur, self.view.bounds.size.width,hauteur)];
            [self.vue setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - hauteur)];
        }];
        [self.detectTapVue setEnabled:NO];
    }
}

// Rotation de l'écran
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (self.scrollAuto)
        [self.vue scrollRangeToVisible:NSMakeRange(self.vue.text.length, 1)];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![[textField text] isEqualToString:@""] && !self.attenteReponse && self.connexionFonctionnelle) {
        [self.timer invalidate];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(majChat:) name:@"EnvoieValide" object:nil];
        [self.reseau postChat:[[[textField text] stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\"]];
        self.attenteReponse = YES;
        self.navigationItem.title = @"Chat ⋙";
    }
    return YES;
}

// Délégué de la vue texte
-(void)textViewDidChangeSelection:(UITextView *)textView {
    if ([textView selectedRange].location != NSNotFound) {
        NSString *chaine = [[textView text] substringWithRange:NSMakeRange(MAX(0, [textView selectedRange].location-7),MIN(17,[textView text].length-[textView selectedRange].location))];
        NSTextCheckingResult *match = [self.regexIdent firstMatchInString:chaine options:0 range:NSMakeRange(0, [chaine length])];
        if (match && [textView selectedRange].length < 9) {
            [self changement:[chaine substringWithRange:[match rangeAtIndex:1]]];
        }
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setToolBar:nil];
    [self setBarreMessage:nil];
    [self setToolBar:nil];
    [self setBarreMessage:nil];
    [self setVue:nil];
    [self setDetectTapVue:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

-(void)applicationDidEnterBackground {
    if (self.visible) {
        [self viewDidDisappear:NO];
        self.visible = YES;
    }
}

-(void)applicationWillEnterForeground {
    if (self.visible)
        [self viewWillAppear:NO];
}

-(void)applicationWillResignActive {}
-(void)applicationDidBecomeActive {}


@end
