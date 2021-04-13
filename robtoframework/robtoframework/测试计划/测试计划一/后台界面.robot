*** Settings ***
Suite Setup       setUp    # 连接数据库
Suite Teardown    tearDown    # 退出数据库｜退出登录
Library           Selenium2Library
Library           RequestsLibrary
Library           Collections
Library           DatabaseLibrary
Resource          my_key.txt

*** Variables ***
@{user}           tel=13055551016    password=c33367701511b4f6020ec61ded352059
@{loginid}        abing    9cbf8a4dcb8e30682b927f352d6559a0    7374ce58be384f97fb15117dd99fba3c
${URL}            http://devm.twlive.net
&{headers}        Content-Type=application/x-www-form-urlencoded

*** Test Cases ***
登录-正常登录
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #断言登陆成功
    should be equal as strings    ${loginin.status_code}    200

登录-账号或密码错误1
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    #帐号密码错误
    ${params2}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[2]
    ${loginin2}    post request    test    happyrunlogin/manage/login    params=${params2}
    ${responsedata2}    to json    ${loginin2.content}
    #断言登陆不成功
    should be equal as strings    ${responsedata2['message']}    账号或密码错误

登录-账号或密码错误2
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=abing100    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #断言账号不存在
    should be equal as strings    ${responsedata['message']}    账号或密码错误

家族长列表
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    ${rs}    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #断言登陆成功
    should be equal as strings    ${loginin.status_code}    200
    #获取直播间管理列表
    ${headers}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    Comment    ${getdata}    get from dictionary    ${reponsedata}    data
    Comment    ${gettoken}    get from dictionary    ${getdata}    acctoken
    Comment    log    ${gettoken}
    Comment    ${headers}    create dictionary    acctoken=${gettoken}
    ${familyList}    get request    test    happyrun/family/allFamilyList    ${headers}
    ${familydata}    to json    ${familyList.content}
    log    ${familydata}
    ${length}    get length    ${familydata['data']}
    @{familyid}    Create List
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${familyid}    ${familydata['data'][${index}]['familyid']}
    END
    log    ${familyid}
    #对比数据库
    @{var}    query    SELECT t1.familyid from mem_family t1,mem_login t2 where \ t1.accno = t2.accno and t1.isdelete = 0 ORDER BY familyid DESC
    log    ${var}
    FOR    ${index}    IN RANGE    ${length}
        ${fam_id_sql}    Set Variable    ${var[${index}][0]}
        Should Be Equal As Strings    ${fam_id_sql}    ${familyid[${index}]}
    END

［024］［进场特效配置列表 ］
    #账号登陆
    ${headers}    create dictionary    Content-Type=application/x-www-form-urlencoded
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    create session    test    ${URL}
    ${loginin}    post request    test    /happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    log    ${responsedata}
    should be equal as strings    ${loginin.status_code}    200
    #［进场特效配置列表
    ${headers}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    pageSize=10    pageNumber=1
    ${list}    get request    test    happyrun/animation/list    ${headers}    params=${params2}
    ${responsedata}    to json    ${list.content}
    ${length}    get length    ${responsedata['data']['list']}
    #取出进场特效名列表
    @{anicode}    Create List
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${anicode}    ${responsedata['data']['list'][${index}]['anicode']}
    END
    log    ${anicode}
    #对比数据库查询结果
    @{var}    query    SELECT anicode FROM mem_animation where isdelete !=9 ORDER BY maxlevel
    log    ${var}
    FOR    ${index}    IN RANGE    ${length}
        ${anicode_sql}    Set Variable    ${var[${index}][0]}
        Should Be Equal As Strings    ${anicode_sql}    ${anicode[${index}]}
    END

［016］［禮物列表 OK］
    comment    后台登陆
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #断言登陆成功
    should be equal as strings    ${loginin.status_code}    200
    ${headers}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    giftname=    pageNumber=1    pageSize=100    total=0    pages=0
    ${giftList}    get request    test    happyrun/live/giftlist    ${headers}    params=${params2}
    ${responsedata}    to json    ${giftList.content}
    Comment    log    ${responsedata}
    ${length}    get length    ${responsedata['data']['list']}
    Comment    log    ${length}
    @{giftid}    Create List
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${giftid}    ${responsedata['data']['list'][${index}]['giftid']}
    END
    log    ${giftid}
    #查数据库
    @{giftid2}    query    SELECT giftid from bas_gift where isdelete = 0 ORDER BY sortby DESC
    log    ${giftid2}
    FOR    ${index}    IN RANGE    ${length}
        ${giftid_sql}    Set Variable    ${giftid2[${index}][0]}
        Should Be Equal As Strings    ${giftid_sql}    ${giftid[${index}]}
    END

［020］［頻道列表 OK］
    comment    登录
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #断言登陆成功
    should be equal as strings    ${loginin.status_code}    200
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    channelname=    pageNumber=1    pageSize=10    total=0    pages=0    sortby=0
    ${channelList}    get request    test    happyrun/live/channellist    ${headers2}    params=${params2}
    ${responsedata2}    to json    ${channelList.content}
    ${length}    get length    ${responsedata2['data']['list']}
    log    ${length}
    @{channelid}    create list
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${channelid}    ${responsedata2['data']['list'][${index}]['channelid']}
    END
    log    ${channelid}
    #查数据库
    @{channelid_Sql}    query    SELECT channelid FROM bas_channel where isdelete = 0 ORDER BY sortby DESC
    FOR    ${index}    IN RANGE    ${length}
        ${channelid2l}    Set Variable    ${channelid_Sql[${index}][0]}
        Should Be Equal As Strings    ${channelid2l}    ${channelid[${index}]}
    END

——［065］［直播线路列表］
    Comment    后台登陆
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #断言登陆成功
    should be equal as strings    ${loginin.status_code}    200
    ${headers}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    pageSize=10    pageNumber=1    nickname=    roomstatus=
    ${anchortenlove}    get request    test    happyrun/anchortenlive/list    ${headers}    params=${params2}
    ${responsedata2}    to json    ${anchortenlove.content}
    comment    计算列表长度
    ${length}    get length    ${responsedata2['data']['list']}
    @{anchortenloveList}    create list
    FOR    ${index}    IN RANGE    ${length}
        APPEND TO LIST    ${anchortenloveList}    ${responsedata2['data']['list'][${index}]['status']}
    END
    LOG    ${anchortenloveList}

［004］［修改密码OK］
    comment    登录账号
    ${headers}    Create Dictionary    Content-Type=application/x-www-form-urlencoded
    Create Session    test    ${URL}    ${headers}
    ${params}    Create Dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    Post Request    test    happyrunlogin/manage/login    params=${params}
    comment    验证登陆成功
    Should Be Equal As Strings    ${loginin.status_code}    200
    ${responsedata}    to json    ${loginin.content}
    ${headers2}    Create Dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    Create Dictionary    oldpsd=${loginid}[1]    newpsd=${loginid}[2]
    ${modifyPassword}    Post Request    test    happyrun/modpassword    params=${params2}    headers=${headers2}
    ${responsedata2}    to json    ${modifyPassword.content}
    log    ${responsedata2}
    should be equal as strings    ${responsedata2['message']}    修改密码成功
    comment    改回来密码
    ${params3}    Create Dictionary    oldpsd=${loginid}[2]    newpsd=${loginid}[1]
    ${modifyPassword3}    Post Request    test    happyrun/modpassword    params=${params3}    headers=${headers2}
    ${responsedata3}    to json    ${modifyPassword3.content}
    log    ${responsedata3}
    should be equal as strings    ${responsedata3['message']}    修改密码成功

［001］［廣告位置列表 OK］
    Comment    后台登陆
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    Should Be Equal As Strings    ${loginin.status_code}    200    #断言登录成功
    comment    获取登录的token
    ${headers}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    seatdesc=    pageNumber=1    pageSize=10    total=0    pages=0
    ${bannerseatList}    get request    test    happyrun/ad/bannerseatList    ${headers}    params=${params2}
    ${responsedata2}    to json    ${bannerseatList.content}
    log    ${responsedata2}
    Comment    获取响应值列表长度
    ${length}    get length    ${responsedata2['data']['list']}
    log    ${length}
    @{list1}    create list
    FOR    ${index}    IN RANGE    ${length}
        Append To List    ${list1}    ${responsedata2['data']['list'][${index}]['bseatid']}
    END
    log    ${list1}
    comment    连接数据库查表
    ${bseatid_sql}    query    select t.bseatid from bd_bannerseat t where t.isdelete = 0 ORDER BY t.bseatid DESC
    log    ${bseatid_sql}
    FOR    ${index}    IN RANGE    ${length}
        ${list2}    Set Variable    ${bseatid_sql[${index}][0]}
        Should Be Equal As Strings    ${list2}    ${list1[${index}]}
    END

［005］［用户管理列表 OK］
    #先登录
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    #验证登录成功
    Should Be Equal As Strings    ${loginin.status_code}    200
    ${responsedata}    to json    ${loginin.content}
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    pageSize=10    pageNumber=1    logintype=1    total=0    pages=0    acclogin=    starttime=
    ${responsedata1}    Get Request    test    happyrun/user/list    params=${params2}    headers=${headers2}
    ${list1}    to json    ${responsedata1.content}
    Comment    log    ${list1}
    ${length}    get length    ${list1['data']['list']}
    Comment    log    ${length}
    @{userlist1}    create list
    FOR    ${index}    IN RANGE    ${length}
        append to list    ${userlist1}    ${list1['data']['list'][${index}]['memid']}
    END
    LOG    ${userlist1}
    #查询数据库
    @{memidList}    query    SELECT t.memid FROM mem_baseinfo t where t.isdelete=0 and t.memorgin='recommend' ORDER BY t.registerdate DESC limit 10;
    log    ${memidList}
    #断言
    FOR    ${index}    IN RANGE    ${length}
        ${userlist2}    Set Variable    ${memidList[${index}][0]}
        Should Be Equal As Strings    ${userlist2}    ${userlist1[${index}]}
    END

［006］［启用/禁用账号OK］
    comment    先登录账号
    ${headers1}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    headers=${headers1}
    ${params1}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params1}
    ${responsedata1}    to json    ${loginin.content}
    log    ${responsedata1}
    #搜索某用户
    ${headers2}    create dictionary    acctoken=${responsedata1['data']['acctoken']}
    log    ${headers2}
    ${params2}    create dictionary    pageSize=10    pageNumber=1    logintype=1    total=0    pages=0    acclogin=13055551012    starttime=
    ${responsedata2}    Get Request    test    happyrun/user/list    params=${params2}    headers=${headers2}
    ${list1}    to json    ${responsedata2.content}
    ${accno}    create dictionary    accno=${list1['data']['list'][0]['accno']}
    ${accstatus1}    create dictionary    accno=${list1['data']['list'][0]['accstatus']}
    comment    数据库查询该用户的状态
    Connect To Database Using Custom Params    pymysql    host='happyrun-test.cu5qq9wqpnls.ap-northeast-1.rds.amazonaws.com',port=3838,user='Hredu',password='Hredu123$Test!',database='happyrun'
    ${userStatus1}    query    SELECT t.accstatus FROM mem_login t where t.acclogin = '13055551012';
    #执行启用/禁用操作
    ${doaccs1}    post request    test    happyrun/user/doAccstatusUser    params=${accno}    headers=${headers2}
    ${responsedata3}    to json    ${doaccs1.content}
    comment    断言操作成功
    Should Be Equal As Strings    ${responsedata3['message']}    操作成功
    #再次查询该用户
    ${params3}    create dictionary    pageSize=10    pageNumber=1    logintype=1    total=0    pages=0    acclogin=13055551012    starttime=
    ${responsedata4}    Get Request    test    happyrun/user/list    params=${params3}    headers=${headers2}
    ${list2}    to json    ${responsedata4.content}
    ${accstatus2}    create dictionary    accno=${list2['data']['list'][0]['accstatus']}
    comment    数据库再次查询该用户的状态
    Connect To Database Using Custom Params    pymysql    host='happyrun-test.cu5qq9wqpnls.ap-northeast-1.rds.amazonaws.com',port=3838,user='Hredu',password='Hredu123$Test!',database='happyrun'
    ${userStatus2}    query    SELECT t.accstatus FROM mem_login t where t.acclogin = '13055551012';
    comment    断言该用户的状态改变
    Should not Be Equal As Strings    ${accstatus1}    ${accstatus2}
    Should not Be Equal As Strings    ${userStatus1}    ${userStatus2}

*** Keywords ***
