*** Settings ***
Suite Setup       setUp    # 登录数据库
Suite Teardown    tearDown    # 退出数据库｜退出登录
Library           Selenium2Library
Library           RequestsLibrary
Library           Collections
Library           DatabaseLibrary
Resource          my_key.txt

*** Variables ***

*** Test Cases ***
［001］［代充人管理-新增］成功
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    livelogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${nickname}    set variable    代充总负责人    #代充昵称
    ${acclogin}    set variable    daichongAuthor    #代充账号
    ${params2}    Create Dictionary    repaymemid=    acclogin=${acclogin}    password=9cbf8a4dcb8e30682b927f352d6559a0    agepassword=123456a    nickname=${nickname}    qq=20200617    webchat=20200617    alipay=20200617    mobileno=13020200617    onlinedates=2016-09-10 00:00:00    onlinedatee=2016-09-10 23:59:59    discountrag=1    status=0
    ${responsedata1}    post request    test    happyrun/agent/user/create    params=${params2}    headers=${headers2}
    comment    断言接口返回“操作成功”
    ${msg1}    to json    ${responsedata1.content}
    Should Be Equal As Strings    ${msg1['message']}    操作成功
    comment    断言数据库最新一条数据为刚创建的
    ${acclogin}    query    SELECT t.nickname FROM mem_repayuser t order by t.createdate DESC LIMIT 1;
    Should Be Equal    ${acclogin[0][0]}    ${nickname}
    comment    把新增的数据删除
    Comment    ${update}    execute sql string    delete from mem_repayuser t where t.nickname ='${nickname}';
    [Teardown]

［001］［代充人管理-新增］账号已存在
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${nickname}    set variable    nickname123666    #代充昵称
    ${acclogin}    set variable    acclogin123    #代充账号
    ${params2}    Create Dictionary    repaymemid=    acclogin=${acclogin}    password=9cbf8a4dcb8e30682b927f352d6559a0    agepassword=123456a    nickname=${nickname}    qq=20200617    webchat=20200617    alipay=20200617    mobileno=13020200617    onlinedates=2016-09-10 00:00:00    onlinedatee=2016-09-10 23:59:59    discountrag=1    status=0
    ${responsedata1}    post request    test    happyrun/agent/user/create    params=${params2}    headers=${headers2}
    comment    断言接口返回“账号已存在”
    ${msg1}    to json    ${responsedata1.content}
    Should Be Equal As Strings    ${msg1['message']}    账号已存在
    [Teardown]

［001］［代充人管理-新增］昵称已存在
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${nickname}    set variable    nickname123    #代充昵称
    ${acclogin}    set variable    acclogin124000    #代充账号
    ${params2}    Create Dictionary    repaymemid=    acclogin=${acclogin}    password=9cbf8a4dcb8e30682b927f352d6559a0    agepassword=123456a    nickname=${nickname}    qq=20200617    webchat=20200617    alipay=20200617    mobileno=13020200617    onlinedates=2016-09-10 00:00:00    onlinedatee=2016-09-10 23:59:59    discountrag=1    status=0
    ${responsedata1}    post request    test    happyrun/agent/user/create    params=${params2}    headers=${headers2}
    comment    断言接口返回“暱称已存在 ”
    ${msg1}    to json    ${responsedata1.content}
    Should Be Equal As Strings    ${msg1['message']}    暱称已存在
    [Teardown]

［002］［代充人管理-详情］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    先查询列表得出一条数据ID
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    acclogin=    nickname=    onlinedates=    onlinedatee=    pageSize=10    pageNumber=1
    ${responsedata1}    get request    test    happyrun/agent/user/list    headers=${headers2}    params=${params2}
    ${list}    to json    ${responsedata1.content}
    ${repaymemid1}    set variable    ${list['data']['list'][0]['repaymemid']}
    ${params3}    create dictionary    repaymemid=${repaymemid1}
    ${responsedata2}    get request    test    happyrun/agent/user/detail    headers=${headers2}    params=${params3}
    ${detail1}    to json    ${responsedata2.content}
    ${nickname1}    set variable    ${detail1['data']['nickname']}
    comment    数据库查询对比昵称
    ${nickname2}    query    select t.nickname from mem_repayuser t where t.repaymemid = '${repaymemid1}';
    Should Be Equal As Strings    ${nickname1}    ${nickname2[0][0]}
    [Teardown]

［005］［代充人管理-列表］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    acclogin=    nickname=    onlinedates=    onlinedatee=    pageSize=10    pageNumber=1
    ${responsedata1}    get request    test    happyrun/agent/user/list    headers=${headers2}    params=${params2}
    ${list}    to json    ${responsedata1.content}
    ${length}    get length    ${list['data']['list']}
    @{nicknameList}    create list
    FOR    ${index}    IN RANGE    ${length}
        append to list    ${nicknameList}    ${list['data']['list'][${index}]['nickname']}
    END
    LOG    ${nicknameList}
    COMMENT    数据库查询并断言
    ${list_sql}    query    select t.nickname from mem_repayuser t ORDER BY t.modifydate DESC;
    ${length2}    get length    ${list_sql}
    should be equal as strings    ${length}    ${length2}    #断言个数相同
    FOR    ${index}    IN RANGE    ${length2}
        ${nicknameList2}    set variable    ${list_sql[${index}][0]}
        log    ${nicknameList2}
        Should Contain    ${nicknameList}    ${nicknameList2}
    END
    [Teardown]

［003］［代充人管理-编辑］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    acclogin=    nickname=    onlinedates=    onlinedatee=    pageSize=10    pageNumber=1
    ${responsedata1}    get request    test    happyrun/agent/user/list    headers=${headers2}    params=${params2}
    ${list}    to json    ${responsedata1.content}
    ${length}    get length    ${list['data']['list']}
    comment    最下面一条的id
    ${repaymemid1}    Set Variable    ${list['data']['list'][${length}-1]['repaymemid']}
    ${nickname}    Set Variable    阿饼编辑代充人
    ${params3}    create dictionary    repaymemid=${repaymemid1}    acclogin=daichong20200617    password=d17124ac6cc4a267d3a9b89b3395154a    nickname=${nickname}    qq=    webchat=    alipay=20200617    mobileno=13020200617    onlinedates=2016-09-10 00:00:00    onlinedatee=2016-09-10 23:59:59    discountrag=2    status=9    agepassword=******
    ${responsedata3}    post request    test    happyrun/agent/user/update    params=${params3}    headers=${headers2}
    comment    断言编辑成功，新昵称为改后名称
    ${newbody}    to json    ${responsedata3.content}
    Should Be Equal As Strings    ${newbody['message']}    操作成功
    ${nickname_sql}    query    select t.nickname from mem_repayuser t where t.repaymemid=${repaymemid1}
    Should Be Equal As Strings    ${nickname_sql[0][0]}    ${nickname}
    [Teardown]

［004］［代充人管理-狀態］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${repaymemid1}    Set Variable    37
    ${params2}    create dictionary    repaymemid=${repaymemid1}    status=0    #启用
    ${status1}    post request    test    happyrun/agent/user/status    params=${params2}    headers=${headers2}
    comment    断言数据库中该条代充人数据状态为0
    ${status_1}    query    select t.status from mem_repayuser t where t.repaymemid=${repaymemid1}
    Should Be Equal As Numbers    ${status_1[0][0]}    0
    ${params3}    create dictionary    repaymemid=${repaymemid1}    status=9    #禁用
    ${status2}    post request    test    happyrun/agent/user/status    params=${params3}    headers=${headers2}
    comment    断言数据库中该条代充人数据状态为0
    ${status_2}    query    select t.status from mem_repayuser t where t.repaymemid=${repaymemid1}
    Should Be Equal As Numbers    ${status_2[0][0]}    9
    [Teardown]

［006］［代充银行卡-新增］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${accountno}    Set Variable    88888999990000088811
    comment    查询数据库，确定没有该卡号
    ${accountno_sql}    query    SELECT t.accountno from sys_repayaccount t where t.accountno = '${accountno}';
    should be empty    ${accountno_sql}
    comment    新增银行卡
    ${params2}    create dictionary    bankid=    nickname=阿饼    bankname=ICBC    accountno=${accountno}    bankaddress=阿饼支行    accountname=阿饼    status=0
    ${body}    post request    test    happyrun/agent/account/create    params=${params2}    headers=${headers2}
    ${responsedata1}    to json    ${body.content}
    comment    断言操作成功，再查数据库存在该卡号
    Should Be Equal    ${responsedata1['message']}    操作成功
    ${accountno_sql}    query    SELECT t.accountno from sys_repayaccount t where t.accountno = '${accountno}';
    Should Be Equal As Numbers    ${accountno_sql[0][0]}    ${accountno}
    [Teardown]

［007］［代充银行卡-详情］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    nickname=    pageSize=10    pageNumber=1
    ${list1}    Get Request    test    happyrun/agent/account/list    ${headers2}    ${params2}
    ${responsedata1}    to json    ${list1.content}
    comment    获取一个银行账号ID
    ${bankid}    set variable    ${responsedata1['data']['list'][0]['bankid']}
    ${params3}    create dictionary    bankid=${bankid}
    ${detail}    Get Request    test    happyrun/agent/account/detail    headers=${headers2}    params=${params3}
    ${body}    to json    ${detail.content}
    comment    断言操作成功，详情与数据库一致
    should be equal as strings    ${body['message']}    操作成功
    ${detail_sql}    query    SELECT t.bankid,t.nickname,t.bankname,t.accountno,t.bankaddress,t.accountname,t.status from sys_repayaccount t where t.bankid ='${bankid}';
    Should Be Equal As Strings    ${body['data']['bankid']}    ${detail_sql[0][0]}
    Should Be Equal As Strings    ${body['data']['nickname']}    ${detail_sql[0][1]}
    Should Be Equal As Strings    ${body['data']['bankname']}    ${detail_sql[0][2]}
    Should Be Equal As Strings    ${body['data']['accountno']}    ${detail_sql[0][3]}
    Should Be Equal As Strings    ${body['data']['bankaddress']}    ${detail_sql[0][4]}
    Should Be Equal As Strings    ${body['data']['accountname']}    ${detail_sql[0][5]}
    Should Be Equal As Strings    ${body['data']['status']}    ${detail_sql[0][6]}
    [Teardown]

［011］［代充银行卡-列表］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    nickname=    pageSize=10    pageNumber=1
    ${list1}    Get Request    test    happyrun/agent/account/list    ${headers2}    ${params2}
    ${responsedata1}    to json    ${list1.content}
    comment    获取卡号列表
    ${length}    get length    ${responsedata1['data']['list']}
    @{accountnoList1}    create list
    FOR    ${index}    IN RANGE    ${length}
        APPEND TO LIST    ${accountnoList1}    ${responsedata1['data']['list'][${index}]['accountno']}
    END
    comment    数据库查询卡号列表
    ${list_sql}    query    SELECT t.accountno from sys_repayaccount t where t.isdelete =0 ORDER BY t.createdate DESC;
    FOR    ${index}    IN RANGE    ${length}
        ${accountnoList2}    set variable    ${list_sql[${index}][0]}
        Should Be Equal As Strings    ${accountnoList2}    ${accountnoList1[${index}]}
    END
    [Teardown]

［008］［代充银行卡-编辑］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${accountno}    Set Variable    88888999990000088822
    ${accountno_new}    Set Variable    88888999997777788888
    comment    新增银行卡
    ${params2}    create dictionary    bankid=    nickname=阿饼创建    bankname=ICBC    accountno=${accountno}    bankaddress=阿饼创建支行    accountname=阿饼创建    status=0
    ${body}    post request    test    happyrun/agent/account/create    params=${params2}    headers=${headers2}
    ${responsedata1}    to json    ${body.content}
    comment    获取新增卡的bankid
    ${bankid_sql}    query    SELECT t.bankid from sys_repayaccount t where t.accountno = '${accountno}';
    ${bankid}    set variable    ${bankid_sql[-1][0]}
    comment    编辑银行卡
    ${params3}    create dictionary    bankid=${bankid}    nickname=阿饼编辑银行卡    bankname=CMB    accountno=${accountno_new}    bankaddress=阿饼编辑银行卡支行    accountname=阿饼编辑银行卡    status=9
    ${body}    post request    test    happyrun/agent/account/update    params=${params3}    headers=${headers2}
    comment    断言该bankid的银行卡数据与编辑后的一致
    ${params4}    create dictionary    bankid=${bankid}
    ${detail}    Get Request    test    happyrun/agent/account/detail    headers=${headers2}    params=${params3}
    ${body}    to json    ${detail.content}
    should be equal as strings    ${body['data']['nickname']}    阿饼编辑银行卡
    should be equal as strings    ${body['data']['accountno']}    ${accountno_new}
    should be equal as strings    ${body['data']['bankaddress']}    阿饼编辑银行卡支行
    should be equal as strings    ${body['data']['accountname']}    阿饼编辑银行卡
    comment    删除该银行卡
    ${params4}    create dictionary    bankid=${bankid}
    ${delete}    post Request    test    happyrun/agent/account/delete    params=${params4}    headers=${headers2}
    [Teardown]

［009］［代充银行卡-删除］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${accountno}    Set Variable    18888999990000088822
    comment    新增银行卡
    ${params2}    create dictionary    bankid=    nickname=阿饼创建    bankname=ICBC    accountno=${accountno}    bankaddress=阿饼创建支行    accountname=阿饼创建    status=0
    ${body}    post request    test    happyrun/agent/account/create    params=${params2}    headers=${headers2}
    ${responsedata1}    to json    ${body.content}
    comment    获取新增卡的bankid
    ${bankid_sql}    query    SELECT t.bankid from sys_repayaccount t where t.accountno = '${accountno}';
    ${bankid}    set variable    ${bankid_sql[-1][0]}
    comment    删除银行卡
    ${params3}    create dictionary    bankid=${bankid}
    ${delete}    post Request    test    happyrun/agent/account/delete    params=${params3}    headers=${headers2}
    comment    断言删除成功，数据库中该bankid的银行卡isdelete为9
    ${responsedata2}    to json    ${delete.content}
    Should Be Equal    ${responsedata2['message']}    操作成功
    ${status}    query    SELECT t.isdelete from sys_repayaccount t where t.bankid = '${bankid}';
    Should Be Equal As Numbers    ${status[0][0]}    9
    [Teardown]

［011］［代充银行卡-状态］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    nickname=    pageSize=10    pageNumber=1
    ${list1}    Get Request    test    happyrun/agent/account/list    ${headers2}    ${params2}
    ${responsedata1}    to json    ${list1.content}
    comment    获取第一个银行卡信息
    ${bankid}    Set Variable    ${responsedata1['data']['list'][0]['bankid']}
    ${status}    Set Variable if    '${responsedata1['data']['list'][0]['status']}'==0    0    9
    ${status2}    Set Variable    !=${status}
    Comment    ${params3}    create dictionary    bankid=${bankid}    status=${status}
    Comment    \    \    \    happyrun/agent/account/status
    [Teardown]
