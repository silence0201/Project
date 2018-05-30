//
//  V2Notification.m
//  V2EX
//
//  Created by 杨晴贺 on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <RegexKitLite/RegexKitLite.h>
#import <SIHTMLParser/HTMLParser.h>

@import CoreText;
@implementation V2Notification

+ (NSArray<V2Notification *> *)getNotificationFromResponseObject:(id)responseObject{
    NSMutableArray *notificationArray = [[NSMutableArray alloc] init];
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        HTMLNode *bodyNode = [parser body];
        NSArray *cellNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"cell" allowPartial:YES];
        
        for (HTMLNode *cellNode in cellNodes) {
            NSArray *tdNodes = [cellNode findChildrenTag:@"td"];
            if (tdNodes.count == 2) {
                V2Notification *model = [[V2Notification alloc] init];
                
                // memeber
                HTMLNode *firstNode = tdNodes[0];
                V2Member *member = [[V2Member alloc] init];
                NSString *avatarUrl = [(HTMLNode *)[firstNode findChildOfClass:@"avatar"] getAttributeNamed:@"src"];
                if ([avatarUrl hasPrefix:@"//"]) {
                    avatarUrl = [@"http:" stringByAppendingString:avatarUrl];
                }
                member.memberAvatarNormal = avatarUrl;
                NSString *userUrl = [(HTMLNode *)[firstNode findChildTag:@"a"] getAttributeNamed:@"href"];
                member.memberName = [userUrl stringByReplacingOccurrencesOfString:@"/member/" withString:@""];
                
                HTMLNode *secondNode = tdNodes[1];
                
                // notification id
                NSString *idRegex = @"deleteNotification\\((.*?),";
                NSString *idString = [secondNode.rawContents stringByMatching:idRegex];
                idString = [idString stringByReplacingOccurrencesOfString:@"deleteNotification(" withString:@""];
                idString = [idString stringByReplacingOccurrencesOfString:@"," withString:@""];
                model.notificationId = idString;
                
                // topic
                V2Topic *topic = [[V2Topic alloc] init];
                NSArray *aNotes = [secondNode findChildrenTag:@"a"];
                for (HTMLNode *aNode in aNotes) {
                    if ([aNode.rawContents rangeOfString:@"reply"].location != NSNotFound) {
                        topic.topicTitle = aNode.contents;
                        
                        NSString *topicURLString = [aNode getAttributeNamed:@"href"];
                        topicURLString = [topicURLString stringByReplacingOccurrencesOfString:@"/t/" withString:@""];
                        topic.topicId = [topicURLString componentsSeparatedByString:@"#"].firstObject;
                        NSString *replyCountString = [topicURLString componentsSeparatedByString:@"#"].lastObject;
                        replyCountString = [replyCountString stringByReplacingOccurrencesOfString:@"reply" withString:@""];
                        topic.topicReplyCount = replyCountString;
                    }
                }
                NSString *dateString = ((HTMLNode *)[secondNode findChildOfClass:@"snow"]).contents;
                model.notificationCreatedDescription = dateString;
                // description
                model.notificationContent = ((HTMLNode *)[secondNode findChildOfClass:@"payload"]).contents;
                if ([secondNode.rawContents rangeOfString:@"里提到了你"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 在 ";
                    model.notificationDescriptionAfter = @" 里提到了你";
                }
                if ([secondNode.rawContents rangeOfString:@"里回复了你"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 在 ";
                    model.notificationDescriptionAfter = @" 里回复了你";
                }
                if ([secondNode.rawContents rangeOfString:@"时提到了你"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 在回复 ";
                    model.notificationDescriptionAfter = @" 时提到了你";
                }
                if ([secondNode.rawContents rangeOfString:@"感谢了你发布的主题"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 感谢了你发布的主题 ";
                    model.notificationDescriptionAfter = @"";
                }
                if ([secondNode.rawContents rangeOfString:@"感谢了你在主题"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 感谢了你在主题 ";
                    model.notificationDescriptionAfter = @" 里的回复";
                }
                if ([secondNode.rawContents rangeOfString:@"收藏了你发布的主题"].location != NSNotFound) {
                    model.notificationDescriptionBefore = @" 收藏了你发布的主题 ";
                    model.notificationDescriptionAfter = @"";
                }
                model.notificationMember = member;
                model.notificationTopic = topic;
                
                if (!model.notificationDescriptionBefore) {
                    model.notificationDescriptionBefore = @" ";
                }
                if (!model.notificationDescriptionAfter) {
                    model.notificationDescriptionAfter = @"";
                }
                
                // AttributedString
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
                
                NSAttributedString *nameAttributedString = [[NSAttributedString alloc] initWithString:model.notificationMember.memberName attributes:@{NSForegroundColorAttributeName: kFontColorBlackBlue, NSFontAttributeName: [UIFont boldSystemFontOfSize:15]}];
                [attributedString appendAttributedString:nameAttributedString];
                
                NSAttributedString *beforeAttributedString = [[NSAttributedString alloc] initWithString:model.notificationDescriptionBefore attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.700 alpha:1.000], NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                [attributedString appendAttributedString:beforeAttributedString];
                
                NSString *topicTitleString = model.notificationTopic.topicTitle;
                if (topicTitleString.length > 25) {
                    topicTitleString = [topicTitleString substringToIndex:25];
                    topicTitleString = [topicTitleString stringByAppendingString:@"..."];
                }
                
                NSAttributedString *topicAttributedString = [[NSAttributedString alloc] initWithString:topicTitleString attributes:@{NSForegroundColorAttributeName: kFontColorBlackBlue, NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                [attributedString appendAttributedString:topicAttributedString];
                
                NSAttributedString *afterAttributedString = [[NSAttributedString alloc] initWithString:model.notificationDescriptionAfter attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.700 alpha:1.000], NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                [attributedString appendAttributedString:afterAttributedString];
                
                CGFloat lineSpace=  2.5;
                
                CTParagraphStyleSetting settings[] =
                {
                    {kCTParagraphStyleSpecifierLineSpacing, sizeof(float), &lineSpace}
                };
                
                CTParagraphStyleRef style;
                style = CTParagraphStyleCreate(settings, sizeof(settings)/sizeof(CTParagraphStyleSetting));
                
                [attributedString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSObject*)style, (NSString*)kCTParagraphStyleAttributeName, nil]
                                          range:NSMakeRange(0, [attributedString length])];
                
                CFRelease(style);
                
                model.notificationTopAttributedString = attributedString;
                if (model.notificationContent) {
                    NSAttributedString *descriptionAttributedString = [[NSAttributedString alloc] initWithString:model.notificationContent attributes:@{NSForegroundColorAttributeName: kFontColorBlackDark, NSFontAttributeName: [UIFont systemFontOfSize:15]}];
                    model.notificationDescriptionAttributedString = descriptionAttributedString;
                }
                
                [notificationArray addObject:model];
            }
        }
        
    }
    return notificationArray ;
}

@end

