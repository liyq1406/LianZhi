//
//  ChildInfo.h
//  LianZhiParent
//
//  Created by jslsxu on 15/1/10.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef CF_ENUM(NSInteger, GenderType) {
    GenderMale = 0,
    GenderFemale,
    GenderSecret,
};

@interface SchoolInfo : TNModelItem<NSCoding>
@property (nonatomic, copy)NSString *schoolID;
@property (nonatomic, copy)NSString *schoolName;
@property (nonatomic, copy)NSString *logoUrl;
@property (nonatomic, strong)NSArray *classes;
@property (nonatomic, strong)NSArray *managedClasses;
@property (nonatomic, strong)NSArray *groups;
@property (nonatomic, strong)NSArray *teachers;
@property (nonatomic, copy)NSString *schoolUrl;
@property (nonatomic, assign)BOOL classIMEnabled;
@property (nonatomic, readonly)NSInteger classNum;
- (NSArray *)allClasses;
@end

@interface TeacherInfo : UserInfo
//@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *course;

@end

@interface FamilyInfo : UserInfo
@property (nonatomic, copy)NSString *relation;

@end

@interface StudentInfo : UserInfo
//@property (nonatomic, assign)GenderType gender;
@property (nonatomic, strong)NSArray *family;
@property (nonatomic, assign)BOOL selected;             //在班级操作中有用
@property (nonatomic, assign)NSInteger attention;       //关注度
@property (nonatomic, assign)BOOL showFocus;
@end

@interface ClassInfo : TNModelItem<NSCoding>
@property (nonatomic, copy)NSString *course;
@property (nonatomic, copy)NSString *grade;
@property (nonatomic, copy)NSString *classID;
@property (nonatomic, copy)NSString *className;
@property (nonatomic, copy)NSString *logoUrl;
@property (nonatomic, strong)NSMutableArray *students;
@property (nonatomic, assign)BOOL recordEnabled;//是否开通成长记录
@property (nonatomic, assign)BOOL canSelected;
@property (nonatomic, assign)BOOL selected;             //在班级操作中有用
@property (nonatomic, assign)NSInteger num;

@end


@interface TeacherGroup : TNModelItem<NSCoding>
@property (nonatomic, copy)NSString *logo;
@property (nonatomic, copy)NSString *groupID;
@property (nonatomic, copy)NSString *groupName;
@property (nonatomic, assign)BOOL canNotice;
@property (nonatomic, strong)NSArray *teachers;
- (BOOL)canChat;
@end