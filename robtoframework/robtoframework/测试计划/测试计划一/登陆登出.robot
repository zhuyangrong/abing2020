*** Settings ***
Library           Selenium2Library
Library           RequestsLibrary
Library           DatabaseLibrary
Resource          my_key.txt

*** Test Cases ***
登陆后台-登陆成功
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[1]
    ${loginin}    post request    test    livelogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${responsedata['info']}    成功
    [Teardown]

登陆后台-登陆密码不正确
    comment    登录成功
    ${headers}    create dictionary    Content-Type=application/json;charset=utf-8
    create session    test    ${URL}    ${headers}
    ${params}    create dictionary    acclogin=${loginid}[0]    password=${loginid}[2]
    ${loginin}    post request    test    livelogin/manage/login    params=${params}
    ${responsedata}    to json    ${loginin.content}
    should be equal as strings    ${responsedata['info']}    账号或密码错误
    [Teardown]

登出后台
    [Setup]    登录后台并连接库-接口
    comment    登出后台
    create session    test    ${URL}    ${head}
    ${loginout}    post request    test    manage/logout    headers=${head}
    ${responsedata2}    to json    ${loginout.content}
    should be equal as strings    ${responsedata2['info']}    成功
    [Teardown]
