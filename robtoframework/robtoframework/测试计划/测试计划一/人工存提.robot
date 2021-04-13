*** Settings ***
Suite Setup       setUp    # 登录数据库
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
人工存提-［001］［人工存提］-存入
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询账户余额
    ${goldnum1}    query    SELECT t.goldnum from mem_baseinfo t where t.memid like '%3721';
    ${goldnum_old}    set variable    ${goldnum1[0][0]}
    log    ${goldnum_old}
    comment    存入一笔
    ${optamt1}    set variable    12.000
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${userid}    set variable    10003721
    ${params2}    create dictionary    ordertype=0    memaccount=${userid}    optamt=${optamt1}    giftamt=0    auditper=0    note=人工存入
    ${body}    post request    test    happyrun/member/art/repay    params=${params2}    headers=${headers2}
    comment    再查询账户余额
    ${goldnum2}    query    SELECT t.goldnum from mem_baseinfo t where t.memid like '%3721';
    ${goldnum_last}    set variable    ${goldnum2[0][0]}
    log    ${goldnum_last}
    comment    断言新查询余额=旧余额+充值的金额
    ${goldnum_new}    evaluate    ${goldnum_old}+${optamt1}
    Should Be Equal As Numbers    ${goldnum_last}    ${goldnum_new}
    [Teardown]

人工存提-［001］［人工存提］-提出
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询账户余额
    ${goldnum1}    query    SELECT t.goldnum from mem_baseinfo t where t.memid like '%3721';
    ${goldnum_old}    set variable    ${goldnum1[0][0]}
    log    ${goldnum_old}
    comment    提出一笔
    ${optamt1}    set variable    12.000
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${userid}    set variable    10003721
    ${params2}    create dictionary    ordertype=1    memaccount=${userid}    optamt=${optamt1}    giftamt=0    auditper=0    note=人工存入
    ${body}    post request    test    happyrun/member/art/repay    params=${params2}    headers=${headers2}
    comment    再查询账户余额
    ${goldnum2}    query    SELECT t.goldnum from mem_baseinfo t where t.memid like '%3721';
    ${goldnum_last}    set variable    ${goldnum2[0][0]}
    log    ${goldnum_last}
    comment    断言新查询余额=旧余额-提出的金额
    ${goldnum_new}    evaluate    ${goldnum_old}-${optamt1}
    Should Be Equal As Numbers    ${goldnum_last}    ${goldnum_new}
    [Teardown]

人工存提-［002］［人工存入记录］-用户ID查询
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${userid}    set variable    10003721
    ${params2}    create dictionary    orderno=    memaccount=${userid}    startdate=    enddate=    pageSize=1000    pageNumber=1
    ${goldnum}    get request    test    happyrun/member/art/deposit/list    headers=${headers2}    params=${params2}
    ${artorderid}    to json    ${goldnum.content}
    comment    列出存入订单号列表
    @{artorderid1}    create list
    ${length}    get length    ${artorderid['data']['list']}
    log    ${length}
    FOR    ${index}    IN RANGE    ${length}
        APPEND TO LIST    ${artorderid1}    ${artorderid['data']['list'][${index}]['artorderid']}
    END
    comment    数据库查询用户的存入记录
    @{artorderid_sql}    query    Select t.artorderid from tra_artrepayorder t where t.memaccount = 10003721 and t.ordertype =0 ORDER BY t.createdate DESC
    log    ${artorderid_sql}
    FOR    ${index}    IN RANGE    ${length}
        ${artorderid2}    Set Variable    ${artorderid_sql[${index}][0]}    #sql查询出来的每一位
        should be equal    ${artorderid2}    ${artorderid1[${index}]}    #接口响应值每一位
    END
    [Teardown]

人工存提-［002］［人工存入记录］-订单号查询
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    先用会员ID查出数据，再取第一条的订单号
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${userid}    set variable    10003721
    ${params2}    create dictionary    orderno=    memaccount=${userid}    startdate=    enddate=    pageSize=1000    pageNumber=1
    ${goldnum}    get request    test    happyrun/member/art/deposit/list    headers=${headers2}    params=${params2}
    ${artorderid}    to json    ${goldnum.content}
    ${first_no}    set variable    ${artorderid['data']['list'][0]['orderno']}
    ${params2}    create dictionary    orderno=${first_no}    memaccount=    startdate=    enddate=    pageSize=1000    pageNumber=1
    ${goldnum2}    get request    test    happyrun/member/art/deposit/list    headers=${headers2}    params=${params2}
    ${artorderid2}    to json    ${goldnum2.content}
    comment    得到artorderid与数据库对比
    ${artorderid_1}    set variable    ${artorderid2['data']['list'][0]['artorderid']}
    ${artorderid_sql}    query    Select t.artorderid from tra_artrepayorder t where t.memaccount = ${userid} and t.ordertype =0 ORDER BY t.createdate DESC limit 1
    ${artorderid_2}    set variable    ${artorderid_sql[0][0]}
    should be equal    ${artorderid_1}    ${artorderid_2}
    [Teardown]

人工存提-［002］［人工提出记录］-用户ID查询
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${userid}    set variable    10003721
    ${params2}    create dictionary    orderno=    memaccount=${userid}    startdate=    enddate=    pageSize=1000    pageNumber=1
    ${goldnum}    get request    test    happyrun/member/art/withdraw/list    headers=${headers2}    params=${params2}
    ${artorderid}    to json    ${goldnum.content}
    comment    列出提出订单号列表
    @{artorderid1}    create list
    ${length}    get length    ${artorderid['data']['list']}
    log    ${length}
    FOR    ${index}    IN RANGE    ${length}
        APPEND TO LIST    ${artorderid1}    ${artorderid['data']['list'][${index}]['artorderid']}
    END
    comment    数据库查询用户的提出记录
    @{artorderid_sql}    query    Select t.artorderid from tra_artrepayorder t where t.memaccount = 10003721 and t.ordertype =1 ORDER BY t.createdate DESC
    log    ${artorderid_sql}
    FOR    ${index}    IN RANGE    ${length}
        ${artorderid2}    Set Variable    ${artorderid_sql[${index}][0]}    #sql查询出来的每一位
        should be equal    ${artorderid2}    ${artorderid1[${index}]}    #接口响应值每一位
    END
    [Teardown]

人工存提-［002］［人工提出记录］-订单号查询
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    先用会员ID查出数据，再取第一条的订单号
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${userid}    set variable    10003721
    ${params2}    create dictionary    orderno=    memaccount=${userid}    startdate=    enddate=    pageSize=1000    pageNumber=1
    ${goldnum}    get request    test    happyrun/member/art/withdraw/list    headers=${headers2}    params=${params2}
    ${artorderid}    to json    ${goldnum.content}
    ${first_no}    set variable    ${artorderid['data']['list'][0]['orderno']}
    ${params2}    create dictionary    orderno=${first_no}    memaccount=    startdate=    enddate=    pageSize=1000    pageNumber=1
    ${goldnum2}    get request    test    happyrun/member/art/withdraw/list    headers=${headers2}    params=${params2}
    ${artorderid2}    to json    ${goldnum2.content}
    comment    得到artorderid与数据库对比
    ${artorderid_1}    set variable    ${artorderid2['data']['list'][0]['artorderid']}
    ${artorderid_sql}    query    Select t.artorderid from tra_artrepayorder t where t.memaccount = ${userid} and t.ordertype =1 ORDER BY t.createdate DESC limit 1
    ${artorderid_2}    set variable    ${artorderid_sql[0][0]}
    should be equal    ${artorderid_1}    ${artorderid_2}
    [Teardown]
