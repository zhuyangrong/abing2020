*** Settings ***
Suite Setup       setUp    # 查询数据库
Suite Teardown    tearDown    # 退出登录｜退出数据库
Library           RequestsLibrary
Library           Selenium2Library
Resource          my_key.txt
Library           DatabaseLibrary
Library           Collections

*** Variables ***
&{headers}        Content-Type=application/x-www-form-urlencoded
@{user}           tel=13055551016    password=c33367701511b4f6020ec61ded352059
@{loginid}        abing    9cbf8a4dcb8e30682b927f352d6559a0    7374ce58be384f97fb15117dd99fba3c
${URL}            http://devm.twlive.net

*** Test Cases ***
短信平台-［008］［短信平台-code］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询短信平台列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${body}    get request    test    happyrun/msg/platform/code    headers=${headers2}
    ${responsedata2}    to json    ${body.content}
    @{codeList1}    create list
    ${length}    get length    ${responsedata2['data']}
    FOR    ${index}    IN RANGE    ${length}
        append to list    ${codeList1}    ${responsedata2['data'][${index}]['code']}
    END
    LOG    ${codeList1}
    comment    断言平台code为列表
    should be equal as strings    ${codeList1}    ['lingkai', 'wangjian', 'meilian', 'aliyun']
    [Teardown]

短信平台-［007］［登录服务器短信平台刷新］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询短信平台列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${body}    get request    test    happyrun/bus/refreshSmgPlatformServer    headers=${headers2}
    comment    断言刷新成功
    ${responsedata2}    to json    ${body.content}
    should be equal as strings    ${responsedata2['message']}    操作成功
    [Teardown]

短信平台-［001］［短信平台-列表］
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #断言登陆成功
    should be equal as strings    ${loginin.status_code}    200
    #短信平台列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    log    ${headers2}
    ${params2}    create dictionary    codename=    pageNumber=1    pageSize=10
    ${body}    get request    test    happyrun/msg/platform/list    headers=${headers2}    params=${params2}
    ${responsedata1}    to json    ${body.content}
    #获取短信平台ID
    @{platformid1}    CREATE LIST
    ${length}    get length    ${responsedata1['data']['list']}
    log    ${length}
    FOR    ${index}    IN RANGE    ${length}
        append to list    ${platformid1}    ${responsedata1['data']['list'][${index}]['platformid']}
    END
    log    ${platformid1}
    comment    对比数据库
    Comment    Connect To Database Using Custom Params    pymysql    host='happyrun-test.cu5qq9wqpnls.ap-northeast-1.rds.amazonaws.com',port=3838,user='Hredu',password='Hredu123$Test!',database='happyrun'
    @{platformid_sql}    query    SELECT t.platformid from sys_msgplatform t where t.isdelete = 0 ORDER BY t.modifydate DESC,status ASC
    log    ${platformid_sql}
    comment    断言
    FOR    ${index}    IN RANGE    ${length}
        ${platformid2}    Set Variable    ${platformid_sql[${index}][0]}
        Should Be Equal As Strings    ${platformid2}    ${platformid1[${index}]}
    END
    [Teardown]

短信平台-［002］［短信平台-详情］
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #断言登陆成功
    should be equal as strings    ${loginin.status_code}    200
    #短信平台列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    log    ${headers2}
    ${params2}    create dictionary    platformid=30
    ${body}    get request    test    happyrun/msg/platform/detail    headers=${headers2}    params=${params2}
    ${responsedata1}    to json    ${body.content}
    #获取短信平台msgdesc
    ${msgdesc1}    set variable    ${responsedata1['data']['msgdesc']}
    #查数据库
    ${msgdesc2}    query    SELECT t.msgdesc from sys_msgplatform t where t.isdelete = 0 ORDER BY t.modifydate DESC,status ASC LIMIT 1;
    comment    断言
    Should Be Equal    ${msgdesc1}    ${msgdesc2[0][0]}
    [Teardown]

短信平台-［005］［短信平台-启用禁用］
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${loginin.status_code}    200
    comment    查询短信平台列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    log    ${headers2}
    ${params2}    create dictionary    codename=    pageNumber=1    pageSize=10
    ${body}    get request    test    happyrun/msg/platform/list    headers=${headers2}    params=${params2}
    ${responsedata1}    to json    ${body.content}
    comment    获取短信平台第一条ID
    ${platformid1}    set variable    ${responsedata1['data']['list'][0]['platformid']}
    comment    禁用
    ${params3}    create dictionary    platformid=${platformid1}    status=9
    ${responsedata3}    post request    test    happyrun/msg/platform/status    params=${params3}    headers=${headers2}
    comment    再次查询该数据的状态
    ${body2}    get request    test    happyrun/msg/platform/list    headers=${headers2}    params=${params2}
    ${responsedata2}    to json    ${body2.content}
    comment    获取短信平台第一条ID
    ${status2}    set variable    ${responsedata2['data']['list'][0]['status']}
    Should Be Equal as strings    ${status2}    9
    comment    启用
    ${params3}    create dictionary    platformid=${platformid1}    status=0
    ${responsedata}    post request    test    happyrun/msg/platform/status    params=${params3}    headers=${headers2}
    comment    再次查询该数据的状态
    ${body3}    get request    test    happyrun/msg/platform/list    headers=${headers2}    params=${params2}
    ${responsedata3}    to json    ${body3.content}
    comment    获取短信平台第一条ID
    ${status3}    set variable    ${responsedata3['data']['list'][0]['status']}
    Should Be Equal as strings    ${status3}    0
    [Teardown]

短信平台-［006］［短信平台-删除］
    #登陆成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #短信平台列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    comment    新增一条短信平台数据
    ${params2}    create dictionary    name=阿饼新创建的短信平台    code=wangjian    sendurl=http://baidu.com    mobilepre=86    msgdesc=阿饼新创建的短信平台    account=abing2020    password=654321    apikey=654321    status=9
    ${body}    post request    test    happyrun/msg/platform/create    params=${params2}    headers=${headers2}
    comment    查询最近创建的平台id
    ${platformid1}    query    SELECT t.platformid from sys_msgplatform t where t.isdelete= 0 and t.msgdesc='阿饼新创建的短信平台';
    ${params3}    create dictionary    platformid=${platformid1[0][0]}
    ${body}    post request    test    happyrun/msg/platform/delete    params=${params3}    headers=${headers2}
    ${responsedata1}    to json    ${body.content}
    #断言数据库最新数据不是刚删除的那条
    ${msgdesc2}    query    SELECT t.msgdesc from sys_msgplatform t where t.isdelete = 0 ORDER BY t.modifydate DESC,status ASC LIMIT 1;
    comment    断言第一条短信平台模板
    Should not Be Equal    ${msgdesc2[0][0]}    阿饼创建的短信平台
    [Teardown]

短信平台-［004］［短信平台-更新］
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    comment    断言登陆成功
    should be equal as strings    ${loginin.status_code}    200
    comment    新增一条短信平台数据
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    ${params2}    create dictionary    name=阿饼新创建的短信平台    code=wangjian    sendurl=http://baidu.com    mobilepre=86    msgdesc=阿饼新创建的短信平台    account=abing2020    password=654321    apikey=654321    status=9
    ${body}    post request    test    happyrun/msg/platform/create    params=${params2}    headers=${headers2}
    Comment    ${responsedata1}    to json    ${body.content}
    comment    查询现表第一条数据
    ${params3}    create dictionary    codename=    pageNumber=1    pageSize=10
    ${body2}    get request    test    happyrun/msg/platform/list    headers=${headers2}    params=${params3}
    ${responsedata2}    to json    ${body2.content}
    ${platformid}    set variable    ${responsedata2['data']['list'][0]['platformid']}
    comment    更新短信平台第一条名称
    ${name1}    set variable    ${responsedata2['data']['list'][0]['name']}
    ${params4}    create dictionary    platformid=${platformid}    name=阿饼更新的短信平台    code=wangjian    msgdesc=阿饼更新的短信平台    sendurl=http://abing2020.net    account=abing2020    password=20200616    apikey=20200616
    ${body3}    post request    test    happyrun/msg/platform/update    params=${params4}    headers=${headers2}
    ${responsedata3}    to json    ${body3.content}
    comment    查询更新后第一条数据的平台名称
    ${params5}    create dictionary    codename=    pageNumber=1    pageSize=10
    ${body4}    get request    test    happyrun/msg/platform/list    headers=${headers2}    params=${params5}
    ${responsedata4}    to json    ${body4.content}
    ${name2}    set variable    ${responsedata4['data']['list'][0]['name']}
    comment    断言更新后第一条的名称已更新为修改后的名称
    Should Be Equal    ${name2}    阿饼更新的短信平台
    comment    删除数据
    ${params6}    create dictionary    platformid=${platformid}
    ${body5}    post request    test    happyrun/msg/platform/delete    params=${params6}    headers=${headers2}
    ${responsedata5}    to json    ${body5.content}
    [Teardown]

短信平台-［003］［短信平台-新增］
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    happyrunlogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #断言登陆成功
    should be equal as strings    ${loginin.status_code}    200
    #短信平台列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    log    ${headers2}
    ${params2}    create dictionary    name=阿饼新创建的短信平台    code=wangjian    sendurl=http://baidu.com    mobilepre=86    msgdesc=阿饼新创建的短信平台    account=abing2020    password=654321    apikey=654321    status=9
    ${body}    post request    test    happyrun/msg/platform/create    params=${params2}    headers=${headers2}
    ${responsedata1}    to json    ${body.content}
    #获取短信平台msgdesc
    Comment    ${msgdesc1}    set variable    ${responsedata1['data']['msgdesc']}
    #查数据库
    ${msgdesc2}    query    SELECT t.msgdesc from sys_msgplatform t where t.isdelete = 0 ORDER BY t.modifydate DESC,status ASC LIMIT 1;
    comment    断言第一条短信平台模板
    Should Be Equal    ${msgdesc2[0][0]}    阿饼新创建的短信平台
    comment    删除新增的数据
    ${params3}    create dictionary    codename=    pageNumber=1    pageSize=10
    ${body}    get request    test    happyrun/msg/platform/list    headers=${headers2}    params=${params3}
    ${responsedata2}    to json    ${body.content}
    ${platformid}    set variable    ${responsedata2['data']['list'][0]['platformid']}
    ${params3}    create dictionary    platformid=${platformid}
    ${body}    post request    test    happyrun/msg/platform/delete    params=${params3}    headers=${headers2}
    [Teardown]

APP_我的关注
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    http://dev.twlive.net:4040    ${headers}
    ${params}    create dictionary    tel=13412345679    password=dc483e80a7a0bd9ef71d8cf973673924
    ${loginin}    post request    test    happyrunlogin/app/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    #断言登陆成功
    should be equal as strings    ${loginin.status_code}    200
    #短信平台列表
    ${headers2}    create dictionary    acctoken=${responsedata['data']['acctoken']}
    log    ${headers2}
    FOR    ${index2}    IN RANGE    100
        ${memid}    Set Variable    ${index2}
    ${params2}    create dictionary    isattention=1    memid=${memid}
    ${myattentionlist}    post request    test    happyrunapp/person/doMyAttention    params=${params2}    headers=${headers2}
    END
    log    ${myattentionlist}
    [Teardown]
