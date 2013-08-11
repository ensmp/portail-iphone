//
//  ConversionChat.m
//  Portail Mines
//
//  Created by Valérian Roche on 23/02/13.
//  Copyright (c) 2013 Valérian Roche. All rights reserved.
//

#import "ConversionChat.h"
#import "ExtensionHTML.h"

@interface ConversionChat()

#define patternUser @"<strong><a href = \"/people/(?:.+?)\">([^<]+)</a></strong>"
@property (nonatomic, strong) NSRegularExpression *regexUser;

#define patternDate @"<span[^>]*>(.+?)</span>"
@property (nonatomic, strong) NSRegularExpression *regexDate;

#define patternEntity @"&#(.+?)"

@property (nonatomic, strong) NSDictionary *attributesUser;
@property (nonatomic, strong) NSDictionary *attributesNormaux;
@property (nonatomic, strong) NSDictionary *attributesDate;

@property (nonatomic, strong) NSDictionary *listeCaracteres;

@end

/*@interface ConversionChat(ParsageEntites)

-(NSString *)stringByReplacingHTMLEntities:(NSString *)HTMLstring;

@end*/

@implementation ConversionChat

-(NSAttributedString *)conversionMessage:(NSString *)messageHTML {
    
    NSMutableAttributedString *resultat = [[NSMutableAttributedString alloc] initWithString:@""];
    
    
    NSTextCheckingResult *match = [self.regexUser firstMatchInString:messageHTML options:0 range:NSMakeRange(0, [messageHTML length])];
    [resultat appendAttributedString:[[NSAttributedString alloc] initWithString:[[messageHTML substringWithRange:[match rangeAtIndex:1]] stringByAppendingString:@" :"] attributes:self.attributesUser]];
    
    int text = [match rangeAtIndex:0].length + [match rangeAtIndex:0].location;
    match = [self.regexDate firstMatchInString:messageHTML options:0 range:NSMakeRange(0, [messageHTML length])];
    
    [resultat appendAttributedString:[[NSAttributedString alloc] initWithString:[[messageHTML substringWithRange:NSMakeRange(text, [match rangeAtIndex:0].location-text)] gtm_stringByUnescapingFromHTML] attributes:self.attributesNormaux]];
    
    [resultat appendAttributedString:[[NSAttributedString alloc] initWithString:[@"- " stringByAppendingString:[messageHTML substringWithRange:[match rangeAtIndex:1]] ] attributes:self.attributesDate]];
    
    return resultat;
}

-(NSRegularExpression *)regexUser {
    if (!_regexUser) _regexUser = [[NSRegularExpression alloc] initWithPattern:patternUser options:NSRegularExpressionCaseInsensitive error:NULL];
    return _regexUser;
}

-(NSRegularExpression *)regexDate {
    if (!_regexDate) _regexDate = [[NSRegularExpression alloc] initWithPattern:patternDate options:NSRegularExpressionCaseInsensitive error:NULL];
    return _regexDate;
}

-(NSDictionary *)attributesDate {
    if (!_attributesDate) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
            _attributesDate = nil;
        else 
            _attributesDate = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIFont systemFontOfSize:[UIFont systemFontSize]-2],[UIColor lightGrayColor], nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, nil]];
    }
    return _attributesDate;
}

-(NSDictionary *)attributesNormaux {
    if (!_attributesNormaux) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0){
            _attributesNormaux = nil;
        }
        else {
            _attributesNormaux = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:[UIFont systemFontSize]] forKey:NSFontAttributeName];
        }
    }
    return _attributesNormaux;
}

-(NSDictionary *)attributesUser {
    if (!_attributesUser) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
            _attributesUser = nil;
        else
            _attributesUser = [NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]] forKey:NSFontAttributeName];
    }
    return _attributesUser;
}

@end

/*@implementation ConversionChat(ParsageEntites)

-(NSString *)stringByReplacingHTMLEntities:(NSString *)stringHTML {
    NSMutableString *chaineModifiable = [stringHTML mutableCopy];
    
    
    
    return [chaineModifiable copy];
}

-(NSDictionary *)listeCaracteres {
    if (!_listeCaracteres) _listeCaracteres = @{
        @(34):@"&quot;",
        @(38) : @"&amp;",
        @(39):@"&apos;",
        @(60):@"&lt;",
        @(62):@"&gt;",
        
        // A.2.1. Latin-1 characters
        @(160):@"&nbsp;",
        @(161):@"&iexcl;",
        @(162):@"&cent;",
        @(163):@"&pound;",
        @(164):@"&curren;",
        @(165):@"&yen;",
        @(166):@"&brvbar;",
        @(167):@"&sect;",
        @(168):@"&uml;",
        @(169):@"&copy;",
        @(170):@"&ordf;",
        @(171):@"&laquo;",
        @(172):@"&not;",
        @(173):@"&shy;",
        @(174):@"&reg;",
        @(175):@"&macr;",
        @(176):@"&deg;",
        @(177):@"&plusmn;",
        @(178):@"&sup2;",
        @(179):@"&sup3;",
        @(180):@"&acute;",
        @(181):@"&micro;",
        @(182):@"&para;",
        @(183):@"&middot;",
        @(184):@"&cedil;",
        @(185):@"&sup1;",
        @(186):@"&ordm;",
        @(187):@"&raquo;",
        @(188):@"&frac14;",
        @(189):@"&frac12;",
        @(190):@"&frac34;",
        @(191):@"&iquest;",
        @(192):@"&Agrave;",
        @(193):@"&Aacute;",
        @(194):@"&Acirc;",
        @(195):@"&Atilde;",
        @(196):@"&Auml;",
        @(197):@"&Aring;",
        @(198):@"&AElig;",
        @(199):@"&Ccedil;",
        @(200):@"&Egrave;",
        @(201):@"&Eacute;",
        @(202):@"&Ecirc;",
        @(203):@"&Euml;",
        @(204):@"&Igrave;",
        @(205):@"&Iacute;",
        @(206):@"&Icirc;",
        @(207):@"&Iuml;",
        @(208):@"&ETH;",
        @(209):@"&Ntilde;",
        @(210):@"&Ograve;",
        @(211):@"&Oacute;",
        @(212):@"&Ocirc;",
        @(213):@"&Otilde;",
        @(214):@"&Ouml;",
        @(215):@"&times;",
        @(216):@"&Oslash;",
        @(217):@"&Ugrave;",
        @(218):@"&Uacute;",
        @(219):@"&Ucirc;",
        @(220):@"&Uuml;",
        @(221):@"&Yacute;",
        @(222):@"&THORN;",
        @(223):@"&szlig;",
        @(224):@"&agrave;",
        @(225):@"&aacute;",
        @(226):@"&acirc;",
        @(227):@"&atilde;",
        @(228):@"&auml;",
        @(229):@"&aring;",
        @(230):@"&aelig;",
        @(231):@"&ccedil;",
        @(232):@"&egrave;",
        @(233):@"&eacute;",
        @(234):@"&ecirc;",
        @(235):@"&euml;",
        @(236):@"&igrave;",
        @(237):@"&iacute;",
        @(238):@"&icirc;",
        @(239):@"&iuml;",
        @(240):@"&eth;",
        @(241):@"&ntilde;",
        @(242):@"&ograve;",
        @(243):@"&oacute;",
        @(244):@"&ocirc;",
        @(245):@"&otilde;",
        @(246):@"&ouml;",
        @(247):@"&divide;",
        @(248):@"&oslash;",
        @(249):@"&ugrave;",
        @(250):@"&uacute;",
        @(251):@"&ucirc;",
        @(252):@"&uuml;",
        @(253):@"&yacute;",
        @(254):@"&thorn;",
        @(255):@"&yuml;",
        
        // A.2.2. Special characters cont'd
        @(338):@"&OElig;",
        @(339):@"&oelig;",
        @(352):@"&Scaron;",
        @(353):@"&scaron;",
        @(376):@"&Yuml;",
        
        // A.2.3. Symbols
        @(402):@"&fnof;",
        
        // A.2.2. Special characters cont'd
        @(710):@"&circ;",
        @(732):@"&tilde;",
        
        // A.2.3. Symbols cont'd
        @(913):@"&Alpha;",
        @(914):@"&Beta;",
        @(915):@"&Gamma;",
        @(916):@"&Delta;",
        @(917):@"&Epsilon;",
        @(918):@"&Zeta;",
        @(919):@"&Eta;",
        @(920):@"&Theta;",
        @(921):@"&Iota;",
        @(922):@"&Kappa;",
        @(923):@"&Lambda;",
        @(924):@"&Mu;",
        @(925):@"&Nu;",
        @(926):@"&Xi;",
        @(927):@"&Omicron;",
        @(928):@"&Pi;",
        @(929):@"&Rho;",
        @(931):@"&Sigma;",
        @(932):@"&Tau;",
        @(933):@"&Upsilon;",
        @(934):@"&Phi;",
        @(935):@"&Chi;",
        @(936):@"&Psi;",
        @(937):@"&Omega;",
        @(945):@"&alpha;",
        @(946):@"&beta;",
        @(947):@"&gamma;",
        @(948):@"&delta;",
        @(949):@"&epsilon;",
        @(950):@"&zeta;",
        @(951):@"&eta;",
        @(952):@"&theta;",
        @(953):@"&iota;",
        @(954):@"&kappa;",
        @(955):@"&lambda;",
        @(956):@"&mu;",
        @(957):@"&nu;",
        @(958):@"&xi;",
        @(959):@"&omicron;",
        @(960):@"&pi;",
        @(961):@"&rho;",
        @(962):@"&sigmaf;",
        @(963):@"&sigma;",
        @(964):@"&tau;",
        @(965):@"&upsilon;",
        @(966):@"&phi;",
        @(967):@"&chi;",
        @(968):@"&psi;",
        @(969):@"&omega;",
        @(977):@"&thetasym;",
        @(978):@"&upsih;",
        @(982):@"&piv;",
        
        // A.2.2. Special characters cont'd
        @(8194):@"&ensp;",
        @(8195):@"&emsp;",
        @(8201):@"&thinsp;",
        @(8204):@"&zwnj;",
        @(8205):@"&zwj;",
        @(8206):@"&lrm;",
        @(8207):@"&rlm;",
        @(8211):@"&ndash;",
        @(8212):@"&mdash;",
        @(8216):@"&lsquo;",
        @(8217):@"&rsquo;",
        @(8218):@"&sbquo;",
        @(8220):@"&ldquo;",
        @(8221):@"&rdquo;",
        @(8222):@"&bdquo;",
        @(8224):@"&dagger;",
        @(8225):@"&Dagger;",
        // A.2.3. Symbols cont'd
        @(8226):@"&bull;",
        @(8230):@"&hellip;",
        
        // A.2.2. Special characters cont'd
        @(8240):@"&permil;",
        
        // A.2.3. Symbols cont'd
        @(8242):@"&prime;",
        @(8243):@"&Prime;",
        
        // A.2.2. Special characters cont'd
        @(8249):@"&lsaquo;",
        @(8250):@"&rsaquo;",
        
        // A.2.3. Symbols cont'd
        @(8254):@"&oline;",
        @(8260):@"&frasl;",
        
        // A.2.2. Special characters cont'd
        @(8364):@"&euro;",
        
        // A.2.3. Symbols cont'd
        @(8465):@"&image;",
        @(8472):@"&weierp;",
        @(8476):@"&real;",
        @(8482):@"&trade;",
        @(8501):@"&alefsym;",
        @(8592):@"&larr;",
        @(8593):@"&uarr;",
        @(8594):@"&rarr;",
        @(8595):@"&darr;",
        @(8596):@"&harr;",
        @(8629):@"&crarr;",
        @(8656):@"&lArr;",
        @(8657):@"&uArr;",
        @(8658):@"&rArr;",
        @(8659):@"&dArr;",
        @(8660):@"&hArr;",
        @(8704):@"&forall;",
        @(8706):@"&part;",
        @(8707):@"&exist;",
        @(8709):@"&empty;",
        @(8711):@"&nabla;",
        @(8712):@"&isin;",
        @(8713):@"&notin;",
        @(8715):@"&ni;",
        @(8719):@"&prod;",
        @(8721):@"&sum;",
        @(8722):@"&minus;",
        @(8727):@"&lowast;",
        @(8730):@"&radic;",
        @(8733):@"&prop;",
        @(8734):@"&infin;",
        @(8736):@"&ang;",
        @(8743):@"&and;",
        @(8744):@"&or;",
        @(8745):@"&cap;",
        @(8746):@"&cup;",
        @(8747):@"&int;",
        @(8756):@"&there4;",
        @(8764):@"&sim;",
        @(8773):@"&cong;",
        @(8776):@"&asymp;",
        @(8800):@"&ne;",
        @(8801):@"&equiv;",
        @(8804):@"&le;",
        @(8805):@"&ge;",
        @(8834):@"&sub;",
        @(8835):@"&sup;",
        @(8836):@"&nsub;",
        @(8838):@"&sube;",
        @(8839):@"&supe;",
        @(8853):@"&oplus;",
        @(8855):@"&otimes;",
        @(8869):@"&perp;",
        @(8901):@"&sdot;",
        @(8968):@"&lceil;",
        @(8969):@"&rceil;",
        @(8970):@"&lfloor;",
        @(8971):@"&rfloor;",
        @(9001):@"&lang;",
        @(9002):@"&rang;",
        @(9674):@"&loz;",
        @(9824):@"&spades;",
        @(9827):@"&clubs;",
        @(9829):@"&hearts;",
        @(9830):@"&diams;"
    };
    return _listeCaracteres;
}

@end*/


