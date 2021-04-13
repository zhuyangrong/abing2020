*** Settings ***
Suite Setup       登录后台并连接库-接口
Library           Selenium2Library
Library           RequestsLibrary
Library           DatabaseLibrary
Resource          my_key.txt
Library           DateTime
Library           String
Library           Collections

*** Test Cases ***
返水管理_彩种列表_大类
    ${params1}    Create Dictionary    categoryId=    lotteryId=    pageNum=1    pageSize=100
    ${res1}    Get Request    test    manage/returnWater/returnWaterSet.json    params=${params1}    headers=${head}
    ${response1}    to json    ${res1.content}
    LOG    ${response1}
    ${length1}    get length    ${response1['data']['lotteryCategories']}
    Comment    ${length2}    get length    ${response1['data']['pageResult']['data']}
    @{lotteryCategories_id}    Create List
    @{lotteryCategories_name}    Create List
    FOR    ${index1}    IN RANGE    ${length1}
        Append To List    ${lotteryCategories_id}    ${response1['data']['lotteryCategories'][${index1}]['id']}
        Append To List    ${lotteryCategories_name}    ${response1['data']['lotteryCategories'][${index1}]['name']}
    END
    LOG    ${lotteryCategories_id}
    LOG    ${lotteryCategories_name}
    COMMENT    断言与数据库数据保持一致
    ${sql}    query    select * from lottery_category t where t.is_delete = 0 ORDER BY t.sort desc
    ${length2}    get length    ${sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${sql[${index2}][0]}    ${response1['data']['lotteryCategories'][${index2}]['id']}
        Should Be Equal As Strings    ${sql[${index2}][1]}    ${response1['data']['lotteryCategories'][${index2}]['name']}
    END

返水管理_彩种列表_小类
    ${params1}    Create Dictionary    categoryId=    lotteryId=    pageNum=1    pageSize=100
    ${res1}    Get Request    test    manage/returnWater/returnWaterSet.json    params=${params1}    headers=${head}
    ${response1}    to json    ${res1.content}
    LOG    ${response1}
    ${length1}    get length    ${response1['data']['pageResult']['data']}
    @{pageResult_id}    Create List
    @{lotteryName}    Create List
    FOR    ${index1}    IN RANGE    ${length1}
        Append To List    ${pageResult_id}    ${response1['data']['pageResult']['data'][${index1}]['id']}
        Append To List    ${lotteryName}    ${response1['data']['pageResult']['data'][${index1}]['lotteryName']}
    END
    LOG    ${pageResult_id}
    LOG    ${lotteryName}
    COMMENT    断言与数据库数据保持一致
    ${sql}    query    select * from lottery_category t where t.is_delete = 0 ORDER BY t.sort desc
    ${length2}    get length    ${sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${sql[${index2}][0]}    ${response1['data']['lotteryCategories'][${index2}]['id']}
        Should Be Equal As Strings    ${sql[${index2}][1]}    ${response1['data']['lotteryCategories'][${index2}]['name']}
    END

返水管理
    ${params1}    Create Dictionary    categoryId=    lotteryId=    pageNum=1    pageSize=10
    ${res1}    Get Request    test    manage/returnWater/returnWaterSet.json    params=${params1}    headers=${head}
    ${response1}    to json    ${res1.content}
    LOG    ${response1}

会员等级列表
    ${params}    create dictionary    pageNo=1    pageSize=100
    ${res1}    post request    test    manage/memLevelConfig/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    log    ${response1}
    ${length1}    get length    ${response1['data']['data']}
    @{idList1}    create list
    FOR    ${index1}    IN RANGE    ${length1}
        append to list    ${idList1}    ${response1['data']['data'][${index1}]['id']}
    END
    log    ${idList1}
    ${id_sql}    query    select t.id from mem_level_config t where t.is_delete = 0 order by t.recharge_amount desc limit 100
    ${length2}    get length    ${id_sql}
    should be equal as strings    ${length1}    ${length2}    #断言个数相同
    FOR    ${index2}    IN RANGE    ${length2}
        ${idList2}    set variable    ${id_sql[${index2}][0]}
        log    ${idList2}
        Should Be Equal As Strings    ${idList2}    ${idList1[${index2}]}
    END

编辑会员等级_成功
    comment    传图片
    ${files}    evaluate    open(r"C:\\Users\\mi\\Pictures\\eeeee.jpg",'rb')    \    #("1.png",open(r"C:\\Users\\mi\\Pictures\\1.png",'rb'),'image/png')
    ${files2}    Create Dictionary    imageFile=${files}
    ${png}    Post Request    test    manage/video/awsupload/uploadSingleImageFile    headers=${head}    files=${files2}
    log    ${png}
    comment    获取当前时间
    Comment    ${time}    get time
    Comment    comment    创建礼物
    Comment    ${keyName}    set variable    ${png['data']['keyName']}
    Comment    ${giftname1}    set variable    ${giftname_edit[0]}
    Comment    ${data}    create dictionary    gifticon=${keyName}    giftname=${giftname1}    gifttype=0    giftdesc=阿饼创建    gold=1    sortby=-800
    Comment    ${res}    post_rf2    ${session_alias}    manage/live/giftsave    data=${data}    head=${head}    files=${files}
    Comment    comment    断言创建礼物成功
    Comment    ${giftname}    query    select t.giftname from bas_gift t where t.isdelete = 0 and t.createdate > '${time}' order by t.giftid desc limit 1
    Comment    Should Be Equal As Strings    ${giftname[0][0]}    ${giftname1}

普通会员列表
    comment    获取列表
    ${params}    Create Dictionary    logintype=1    accstatus=    memlevel=    nickname=    uniqueId=    startTime=    endTime=    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    @{accloginList}    Create List
    @{nicknameList}    Create List
    ${length1}    get length    ${response1['data']['data']}
    FOR    ${index1}    IN RANGE    ${length1}
        APPEND TO LIST    ${accloginList}    ${response1['data']['data'][${index1}]['acclogin']}
        APPEND TO LIST    ${nicknameList}    ${response1['data']['data'][${index1}]['nickname']}
    END
    log    ${accloginList}
    log    ${nicknameList}
    comment    数据库获取列表
    ${sql}    query    SELECT ml.acclogin,mb.memid,mb.unique_id as uniqueId,mb.accno,mb.nickname,mb.goldnum,mb.consume_amount \ \ \ \ \ \ \ \ as consumeAmount,mb.no_withdrawal_amount as noWithdrawalAmount, \ \ \ \ \ \ \ \ mb.remark,ml.lastlogindate , \ ml.accstatus,ml.logintype,mle.memlevel as memlevel \ \ \ \ \ \ \ \ FROM mem_login ml \ \ \ \ \ \ \ \ INNER JOIN mem_baseinfo mb ON ml.accno = mb.accno AND mb.is_delete = b'0' \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ INNER JOIN mem_level mle on ml.accno = mle.accno and mle.is_delete = b'0' \ \ \ \ \ \ \ where ml.logintype = 1 \ \ \ \ \ \ \ \ ORDER BY CAST(mle.memlevel as UNSIGNED) DESC,mb.create_time DESC , ml.accstatus asc limit 10;    #排序搞不通
    log    ${sql}
    ${length2}    get length    ${sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Comment    Should Be Equal As Strings    ${sql[${index2}][0]}    ${response1['data']['data'][${index2}]['acclogin']}
        Should Be Equal As Strings    ${sql[${index2}][4]}    ${response1['data']['data'][${index2}]['nickname']}
    END

普通会员列表_检索_今天
    comment    获取今天时间
    ${today}    Get Current Date    result_format=%Y-%m-%d
    ${today_arr}    set variable    ${today}
    ${time_begin}    set variable    ${today_arr} 00:00:00
    ${time_end}    set variable    ${today_arr} 23:59:59
    ${params}    Create Dictionary    logintype=1    accstatus=    memlevel=    nickname=    uniqueId=    startTime=${time_begin}    endTime=${time_end}    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    @{accloginList}    Create List
    ${length1}    get length    ${response1['data']['data']}
    FOR    ${index1}    IN RANGE    ${length1}
        APPEND TO LIST    ${accloginList}    ${response1['data']['data'][${index1}]['acclogin']}
    END
    log    ${accloginList}
    comment    数据库获取列表
    ${acclogin_sql}    query    SELECT ml.acclogin,mb.memid,mb.unique_id as uniqueId,mb.accno,mb.nickname,mb.goldnum,mb.consume_amount \ \ \ \ \ \ \ \ as consumeAmount,mb.no_withdrawal_amount as noWithdrawalAmount, \ \ \ \ \ \ \ \ mb.remark,ml.lastlogindate , \ ml.accstatus,ml.logintype,mle.memlevel as memlevel \ \ \ \ \ \ \ \ FROM mem_login ml \ \ \ \ \ \ \ \ INNER JOIN mem_baseinfo mb ON ml.accno = mb.accno AND mb.is_delete = b'0' and mb.create_time BETWEEN '${time_begin}' and '${time_end}'\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ INNER JOIN mem_level mle on ml.accno = mle.accno and mle.is_delete = b'0' \ \ \ \ \ \ \ where ml.logintype = 1 \ \ \ \ \ \ \ \ ORDER BY CAST(mle.memlevel as UNSIGNED) DESC,mb.create_time DESC , ml.accstatus asc limit 10;    #排序搞不通
    log    ${acclogin_sql}
    ${length2}    get length    ${acclogin_sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${acclogin_sql[${index2}][0]}    ${response1['data']['data'][${index2}]['acclogin']}
    END

普通会员列表_检索_昨天
    comment    获取时间
    ${time}    get time    year month day    NOW -1 day
    log    ${time}
    ${time_begin}    set variable    ${time[0]}-${time[1]}-${time[2]} 00:00:00
    ${time_end}    set variable    ${time[0]}-${time[1]}-${time[2]} 23:59:59
    ${params}    Create Dictionary    logintype=1    accstatus=    memlevel=    nickname=    uniqueId=    startTime=${time_begin}    endTime=${time_end}    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    @{accloginList}    Create List
    ${length1}    get length    ${response1['data']['data']}
    FOR    ${index1}    IN RANGE    ${length1}
        APPEND TO LIST    ${accloginList}    ${response1['data']['data'][${index1}]['acclogin']}
    END
    log    ${accloginList}
    comment    数据库获取列表
    ${acclogin_sql}    query    SELECT ml.acclogin,mb.memid,mb.unique_id as uniqueId,mb.accno,mb.nickname,mb.goldnum,mb.consume_amount \ \ \ \ \ \ \ \ as consumeAmount,mb.no_withdrawal_amount as noWithdrawalAmount, \ \ \ \ \ \ \ \ mb.remark,ml.lastlogindate , \ ml.accstatus,ml.logintype,mle.memlevel as memlevel \ \ \ \ \ \ \ \ FROM mem_login ml \ \ \ \ \ \ \ \ INNER JOIN mem_baseinfo mb ON ml.accno = mb.accno AND mb.is_delete = b'0' and mb.create_time BETWEEN '${time_begin}' and '${time_end}'\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ INNER JOIN mem_level mle on ml.accno = mle.accno and mle.is_delete = b'0' \ \ \ \ \ \ \ where ml.logintype = 1 \ \ \ \ \ \ \ \ ORDER BY CAST(mle.memlevel as UNSIGNED) DESC,mb.create_time DESC , ml.accstatus asc limit 10;    #排序搞不通
    log    ${acclogin_sql}
    ${length2}    get length    ${acclogin_sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${acclogin_sql[${index2}][0]}    ${response1['data']['data'][${index2}]['acclogin']}
    END

普通会员列表_检索_近七天
    comment    获取时间
    comment    获取七天前0点
    ${time1}    get time    year month day    NOW -6 day
    ${time_begin}    set variable    ${time1[0]}-${time1[1]}-${time1[2]} 00:00:00
    comment    获取今天结束时
    ${time2}    get time    year month day    NOW
    ${time_end}    set variable    ${time2[0]}-${time2[1]}-${time2[2]} 23:59:59
    ${params}    Create Dictionary    logintype=1    accstatus=    memlevel=    nickname=    uniqueId=    startTime=${time_begin}    endTime=${time_end}    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    @{accloginList}    Create List
    ${length1}    get length    ${response1['data']['data']}
    FOR    ${index1}    IN RANGE    ${length1}
        APPEND TO LIST    ${accloginList}    ${response1['data']['data'][${index1}]['acclogin']}
    END
    log    ${accloginList}
    comment    数据库获取列表
    ${acclogin_sql}    query    SELECT ml.acclogin,mb.memid,mb.unique_id as uniqueId,mb.accno,mb.nickname,mb.goldnum,mb.consume_amount \ \ \ \ \ \ \ \ as consumeAmount,mb.no_withdrawal_amount as noWithdrawalAmount, \ \ \ \ \ \ \ \ mb.remark,ml.lastlogindate , \ ml.accstatus,ml.logintype,mle.memlevel as memlevel \ \ \ \ \ \ \ \ FROM mem_login ml \ \ \ \ \ \ \ \ INNER JOIN mem_baseinfo mb ON ml.accno = mb.accno AND mb.is_delete = b'0' and mb.create_time BETWEEN '${time_begin}' and '${time_end}'\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ INNER JOIN mem_level mle on ml.accno = mle.accno and mle.is_delete = b'0' \ \ \ \ \ \ \ where ml.logintype = 1 \ \ \ \ \ \ \ \ ORDER BY CAST(mle.memlevel as UNSIGNED) DESC,mb.create_time DESC , ml.accstatus asc limit 10;    #排序搞不通
    log    ${acclogin_sql}
    ${length2}    get length    ${acclogin_sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${acclogin_sql[${index2}][0]}    ${response1['data']['data'][${index2}]['acclogin']}
    END

普通会员列表_检索_本月
    comment    获取本月时间
    ${time}    get time    year month day    NOW
    log    ${time}
    ${time_begin}    set variable    ${time[0]}-${time[1]}-01 00:00:00
    ${time_mid1}    set variable    ${time[1]}
    ${time_mid2}    Convert To Integer    ${time_mid1}
    ${time_mid3}    evaluate    ${time_mid2}+1
    ${time_mid4}    set variable    ${time[0]}-${time_mid3}-01 00:00:00
    log    ${time_mid4}
    ${time_mid5}=    Convert Date    ${time_mid4}
    log    ${time_mid5}
    ${time_mid6}    Add Time To Date    ${time_mid5}    -00:00:01.000
    log    ${time_mid6}
    ${time_end}    set variable    ${time_mid6}
    log    ${time_end}
    ${params}    Create Dictionary    logintype=1    accstatus=    memlevel=    nickname=    uniqueId=    startTime=${time_begin}    endTime=${time_end}    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    @{accloginList}    Create List
    ${length1}    get length    ${response1['data']['data']}
    FOR    ${index1}    IN RANGE    ${length1}
        APPEND TO LIST    ${accloginList}    ${response1['data']['data'][${index1}]['acclogin']}
    END
    log    ${accloginList}
    comment    数据库获取列表
    ${acclogin_sql}    query    SELECT ml.acclogin,mb.memid,mb.unique_id as uniqueId,mb.accno,mb.nickname,mb.goldnum,mb.consume_amount \ \ \ \ \ \ \ \ as consumeAmount,mb.no_withdrawal_amount as noWithdrawalAmount, \ \ \ \ \ \ \ \ mb.remark,ml.lastlogindate , \ ml.accstatus,ml.logintype,mle.memlevel as memlevel \ \ \ \ \ \ \ \ FROM mem_login ml \ \ \ \ \ \ \ \ INNER JOIN mem_baseinfo mb ON ml.accno = mb.accno AND mb.is_delete = b'0' and mb.create_time BETWEEN '${time_begin}' and '${time_end}'\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ INNER JOIN mem_level mle on ml.accno = mle.accno and mle.is_delete = b'0' \ \ \ \ \ \ \ where ml.logintype = 1 \ \ \ \ \ \ \ \ ORDER BY CAST(mle.memlevel as UNSIGNED) DESC,mb.create_time DESC , ml.accstatus asc limit 10;    #排序搞不通
    log    ${acclogin_sql}
    ${length2}    get length    ${acclogin_sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${acclogin_sql[${index2}][0]}    ${response1['data']['data'][${index2}]['acclogin']}
    END

普通会员列表_检索_上月
    comment    获取上个月时间
    ${time}    get time    year month day    NOW
    log    ${time}
    comment    获取上月最后一秒时间
    ${time_end_mid1}    set variable    ${time[0]}-${time[1]}-01 00:00:00
    ${time_end_mid2}    Convert Date    ${time_end_mid1}
    ${time_end}    Add Time To Date    ${time_end_mid2}    -00:00:01.000
    log    ${time_end}
    comment    获取上月第一秒时间
    ${time_begin_mid1}    set variable    ${time[1]}
    ${time_begin_mid2}    Convert To Integer    ${time_begin_mid1}
    ${time_begin_mid3}    evaluate    ${time_begin_mid2}-1
    ${time_begin}    set variable    ${time[0]}-${time_begin_mid3}-01 00:00:00
    ${params}    Create Dictionary    logintype=1    accstatus=    memlevel=    nickname=    uniqueId=    startTime=${time_begin}    endTime=${time_end}    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    @{accloginList}    Create List
    ${length1}    get length    ${response1['data']['data']}
    FOR    ${index1}    IN RANGE    ${length1}
        APPEND TO LIST    ${accloginList}    ${response1['data']['data'][${index1}]['acclogin']}
    END
    log    ${accloginList}
    comment    数据库获取列表
    ${acclogin_sql}    query    SELECT ml.acclogin,mb.memid,mb.unique_id as uniqueId,mb.accno,mb.nickname,mb.goldnum,mb.consume_amount \ \ \ \ \ \ \ \ as consumeAmount,mb.no_withdrawal_amount as noWithdrawalAmount, \ \ \ \ \ \ \ \ mb.remark,ml.lastlogindate , \ ml.accstatus,ml.logintype,mle.memlevel as memlevel \ \ \ \ \ \ \ \ FROM mem_login ml \ \ \ \ \ \ \ \ INNER JOIN mem_baseinfo mb ON ml.accno = mb.accno AND mb.is_delete = b'0' and mb.create_time BETWEEN '${time_begin}' and '${time_end}'\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ INNER JOIN mem_level mle on ml.accno = mle.accno and mle.is_delete = b'0' \ \ \ \ \ \ \ where ml.logintype = 1 \ \ \ \ \ \ \ \ ORDER BY CAST(mle.memlevel as UNSIGNED) DESC,mb.create_time DESC , ml.accstatus asc limit 10;    #排序搞不通
    log    ${acclogin_sql}
    ${length2}    get length    ${acclogin_sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${acclogin_sql[${index2}][0]}    ${response1['data']['data'][${index2}]['acclogin']}
    END

普通会员列表_启用/禁用会员
    comment    获取列表
    ${params}    Create Dictionary    logintype=1    accstatus=    memlevel=    nickname=    uniqueId=    startTime=    endTime=    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    comment    接口返回的第一个会员用作下一步骤的参数
    ${accno1}    Set Variable    ${response1['data']['data'][0]['accno']}
    ${nickname}    Set Variable    ${response1['data']['data'][0]['nickname']}
    comment    查询第一个会员的启用或禁用状态
    ${accstatus1}    Set Variable    ${response1['data']['data'][0]['accstatus']}
    comment    执行动作
    ${params2}    Create Dictionary    accno=${accno1}
    ${res2}    Post Request    test    manage/user/doAccstatusUser    params=${params2}    headers=${head}
    ${response2}    to json    ${res2.content}
    comment    查询执行动作后的启用或禁用状态
    ${params3}    Create Dictionary    logintype=1    accstatus=    memlevel=    nickname=${nickname}    uniqueId=    startTime=    endTime=    pageNo=1    pageSize=10
    ${res3}    get Request    test    manage/user/list    params=${params3}    headers=${head}
    ${response3}    to json    ${res3.content}
    ${accstatus2}    Set Variable    ${response3['data']['data'][0]['accstatus']}
    COMMENT    断言执行动作前后，会员状态不一致，一个是1一个是9
    Should Not Be Equal As Strings    ${accstatus1}    ${accstatus2}

普通会员列表_修改密码成功
    comment    获取列表状态为启用的数据列表
    ${params}    Create Dictionary    logintype=1    accstatus=1    memlevel=    nickname=    uniqueId=    startTime=    endTime=    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    comment    接口返回的第一个会员用作下一步骤的参数
    ${acclogin1}    Set Variable    ${response1['data']['data'][0]['acclogin']}
    ${params2}    Create Dictionary    surePasWord=${loginid}[1]    pwd=${loginid}[1]    type=0    acclogin=${acclogin1}
    ${res2}    post Request    test    manage/user/updatePassword    params=${params2}    headers=${head}
    ${response2}    to json    ${res2.content}
    COMMENT    断言修改密码成功
    Should Be Equal As Strings    ${response2['data']}    success
    Should Be Equal As Strings    ${response2['info']}    成功
    COMMENT    使用修改后的密码，在前端能登录
    ${params3}    Create Dictionary    password=${loginid}[1]    latitude=131.04925573429551    tel=${acclogin1}    longitude=31.315590522490712
    ${res3}    post Request    test    livelogin/app/login    params=${params3}    headers=${head}
    ${response3}    to json    ${res3.content}
    Should Be Equal As Strings    ${response3['info']}    成功

普通会员列表_修改密码失败
    comment    获取列表状态为禁用的数据列表
    ${params}    Create Dictionary    logintype=1    accstatus=9    memlevel=    nickname=    uniqueId=    startTime=    endTime=    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    comment    接口返回的第一个会员用作下一步骤的参数
    ${acclogin1}    Set Variable    ${response1['data']['data'][0]['acclogin']}
    ${params2}    Create Dictionary    surePasWord=dc483e80a7a0bd9ef71d8cf973673924    pwd=dc483e80a7a0bd9ef71d8cf973673924    type=0    acclogin=${acclogin1}
    ${res2}    post Request    test    manage/user/updatePassword    params=${params2}    headers=${head}
    ${response2}    to json    ${res2.content}
    COMMENT    断言修改密码失败
    Should Be Equal As Strings    ${response2['data']}    None
    Should Be Equal As Strings    ${response2['info']}    修改密码失败

普通会员列表_查看会员详情
    comment    获取列表
    ${params}    Create Dictionary    logintype=1    accstatus=    memlevel=    nickname=    uniqueId=    startTime=    endTime=    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    comment    接口返回的第一个会员用作下一步骤的参数
    ${memid1}    Set Variable    ${response1['data']['data'][0]['memid']}
    ${params2}    Create Dictionary    memid=${memid1}    Manage=true
    ${res2}    get Request    test    manage/user/userDetail    params=${params2}    headers=${head}
    ${response}    to json    ${res2.content}
    COMMENT    断言接口返回值与库查询结果一致
    ${sql}    query    SELECT mb.memid,ml.accno,mb.clintipadd,mb.goldnum,mb.mobileno,mb.unique_id,mb.nickname,mb.sex,mb.recomcode,mb.describes,mb.last_login_dev,mb.logincountry,mb.memorgin, mle.memlevel,mb.consume_amount,mb.no_withdrawal_amount,mb.pay_amount,mb.pay_max,mb.pay_first,mb.pay_num ,mm.accountno,mm.accountname,mm.bankname,mm.bankaddress \ \ \ \ \ \ \ \ FROM mem_login ml \ \ \ \ \ \ \ \ INNER JOIN mem_baseinfo mb ON ml.accno = mb.accno AND mb.is_delete = b'0' \ \ \ \ \ \ \ \ INNER JOIN mem_bankaccount mm on mm.accno = ml.accno \ \ \ \ \ \ \ \ INNER JOIN mem_level mle on ml.accno = mle.accno and mle.is_delete = b'0' \ \ \ \ \ \ \ where ml.logintype = 1 \ and mb.memid = '${memid1}';
    LOG    ${sql}
    Should Be Equal As Strings    ${response['data']['memid']}    ${sql[0][0]}
    Should Be Equal As Strings    ${response['data']['accno']}    ${sql[0][1]}
    Should Be Equal As Strings    ${response['data']['clintipadd']}    ${sql[0][2]}
    Should Be Equal As Integers    ${response['data']['goldnum']}    ${sql[0][3]}
    Should Be Equal As Strings    ${response['data']['mobileno']}    ${sql[0][4]}
    Should Be Equal As Strings    ${response['data']['uniqueId']}    ${sql[0][5]}
    Should Be Equal As Strings    ${response['data']['nickname']}    ${sql[0][6]}
    Should Be Equal As Strings    ${response['data']['sex']}    ${sql[0][7]}
    Should Be Equal As Strings    ${response['data']['recomcode']}    ${sql[0][8]}
    Should Be Equal As Strings    ${response['data']['describes']}    ${sql[0][9]}
    Should Be Equal As Strings    ${response['data']['lastLoginDev']}    ${sql[0][10]}
    Should Be Equal As Strings    ${response['data']['logincountry']}    ${sql[0][11]}
    Should Be Equal As Strings    ${response['data']['memorgin']}    ${sql[0][12]}
    Should Be Equal As Strings    ${response['data']['memlevel']}    ${sql[0][13]}
    Should Be Equal As Strings    ${response['data']['consumeAmount']}    ${sql[0][14]}
    Should Be Equal As Numbers    ${response['data']['noWithdrawalAmount']}    ${sql[0][15]}
    Should Be Equal As Numbers    ${response['data']['payAmount']}    ${sql[0][16]}
    Should Be Equal As Numbers    ${response['data']['payMax']}    ${sql[0][17]}
    Should Be Equal As Numbers    ${response['data']['payFirst']}    ${sql[0][18]}
    Should Be Equal As Strings    ${response['data']['payNum']}    ${sql[0][19]}
    Should Be Equal As Strings    ${response['data']['accountno']}    ${sql[0][20]}
    Should Be Equal As Strings    ${response['data']['accountname']}    ${sql[0][21]}
    Should Be Equal As Strings    ${response['data']['bankname']}    ${sql[0][22]}
    Should Be Equal As Strings    ${response['data']['bankaddress']}    ${sql[0][23]}

普通会员列表_获取银行列表
    comment    获取列表
    ${params}    Create Dictionary    busparamcode=banklist
    ${res1}    get Request    test    manage/busparam/getChild    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    COMMENT    获取银行类型列表
    ${length1}    get length    ${response1['data']}
    @{busparamname1}    create list
    FOR    ${index1}    IN RANGE    ${length1}
        APPEND TO LIST    ${busparamname1}    ${response1['data'][${index1}]['busparamname']}
    END
    log    ${busparamname1}
    COMMENT    比对 数据库银行列表
    ${sql}    query    select t.busparamname from sys_busparameter t where t.pbusparamcode = 'banklist'
    ${length2}    get length    ${sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${sql[${index2}][0]}    ${response1['data'][${index2}]['busparamname']}
    END

普通会员列表_编辑会员详情
    comment    获取特定会员
    ${params}    Create Dictionary    logintype=1    accstatus=    memlevel=18    nickname=好几桶阳春面21    uniqueId=BRBKDO57    startTime=    endTime=    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    comment    接口返回的第一个会员用作下一步骤的参数
    ${memid1}    Set Variable    ${response1['data']['data'][0]['memid']}
    ${params2}    Create Dictionary    memid=${memid1}    accountname=测试一专用    describes=测试一下专用    memlevel=18    locked=false    uniqueId=BRBKDO57    nickname=好几桶阳春面21    bankaddress=测试一开户行    accountno=5555555555555555555    accstatus=9    accno=1f68037a91f44500aeb582aab1ebfede    memname=    mobileno=13055551025    sex=    idcardtype=
    ...    idcardno=    idcardfront=    idcardback=    birthday=    nationality=    headimg=https://liveuatstore.s3-ap-southeast-1.amazonaws.com/avatar/500c1cf1aab04721a53075b80fc41e7bv37luo.jpg    registerdate=1595905481000    recomcode=CILB1I    tag=    clintipadd=103.114.91.102    registerIp=    registerDev=    lastLoginDev=iPhone SE2    logincountry=柬埔寨    memfeatures=    memorgin=regist
    ...    fansnum=0    goldnum=111369    waitAmount=0    withdrawalRemainder=0    betAmount=0    payAmount=113100    payMax=100000    payFirst=100000    payNum=5    withdrawalAmount=0    withdrawalMax=0    withdrawalFirst=0    withdrawalNum=0    consumeAmount=3176    noWithdrawalAmount=111369    chatStatus=1
    ...    freezeStatus=0    betStatus=1    backwaterStatus=1    shareOrderStatus=0    logintype=1    openid=    sitearea=    wechat=    chatnickname=    forbidTalkType=    forbidInType=    forbidTalkStart=    forbidTalkEnd=    forbidInStart=    forbidInEnd=    isDelete=false
    ...    createUser=1f68037a91f44500aeb582aab1ebfede    createTime=1595905480000    updateUser=3d14189a3ecc40f6bec63bc01840a6a7    updateTime=1600263936000    remark=    cgNickname=true    proxyUrl=    refUniqueId=    lastlogindate=1600229097000    bankname=ICBC
    ${res2}    post Request    test    manage/user/updateUser    params=${params2}    headers=${head}
    ${response}    to json    ${res2.content}
    COMMENT    断言编辑成功
    Should Be Equal As Strings    ${response['data']}    success
    Should Be Equal As Strings    ${response['info']}    成功

普通会员列表_编辑备注信息
    comment    获取特定会员
    ${params}    Create Dictionary    logintype=1    accstatus=    memlevel=18    nickname=好几桶阳春面21    uniqueId=BRBKDO57    startTime=    endTime=    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/user/list    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    comment    接口返回的第一个会员用作下一步骤的参数
    ${memid1}    Set Variable    ${response1['data']['data'][0]['memid']}
    ${remark}    Set Variable    测试专用备注信息
    ${params2}    Create Dictionary    memid=${memid1}    remark=${remark}
    ${res2}    post Request    test    manage/user/updateRemark    params=${params2}    headers=${head}
    ${response}    to json    ${res2.content}
    COMMENT    断言编辑成功
    Should Be Equal As Strings    ${response['data']}    success
    Should Be Equal As Strings    ${response['info']}    成功
    COMMENT    断言该会员备注信息为改后的内容
    ${params3}    Create Dictionary    memid=${memid1}    Manage=true
    ${res3}    get Request    test    manage/user/userDetail    params=${params3}    headers=${head}
    ${response2}    to json    ${res3.content}
    COMMENT    断言接口返回值与库查询结果一致
    ${sql}    query    SELECT mb.remark \ \ \ \ \ \ \ \ FROM mem_login ml \ \ \ \ \ \ \ \ INNER JOIN mem_baseinfo mb ON ml.accno = mb.accno AND mb.is_delete = b'0' \ \ \ \ \ \ \ \ INNER JOIN mem_bankaccount mm on mm.accno = ml.accno \ \ \ \ \ \ \ \ INNER JOIN mem_level mle on ml.accno = mle.accno and mle.is_delete = b'0' \ \ \ \ \ \ \ where ml.logintype = 1 \ and mb.memid = '${memid1}';
    LOG    ${sql}
    Should Be Equal As Strings    ${remark}    ${sql[0][0]}

试玩账号列表
    comment    获取列表
    ${params}    Create Dictionary    acclogin=    accstatus=    memlevel=    nickname=    uniqueId=    pageNo=1    pageSize=1000
    ${res1}    get Request    test    manage/trial/trialList    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    @{accloginList}    Create List
    ${length1}    get length    ${response1['data']['data']}
    FOR    ${index1}    IN RANGE    ${length1}
        APPEND TO LIST    ${accloginList}    ${response1['data']['data'][${index1}]['acclogin']}
    END
    log    ${accloginList}
    comment    数据库获取列表
    ${acclogin_sql}    query    SELECT ml.acclogin, mb.memid,mb.unique_id as uniqueId,mb.accno,mb.nickname,mb.goldnum,mb.consume_amount \ \ \ \ \ \ \ \ as consumeAmount,mb.no_withdrawal_amount as noWithdrawalAmount, \ \ \ \ \ \ \ \ mb.remark,ml.lastlogindate , \ ml.accstatus,ml.logintype,mle.memlevel as memlevel \ \ \ \ \ \ \ \ ,mb.create_user as createUser, ml.clintipadd as clintipadd ,mb.create_time as createTime \ \ \ \ \ \ \ \ FROM mem_login ml \ \ \ \ \ \ \ \ INNER JOIN mem_baseinfo mb ON ml.accno = mb.accno AND mb.is_delete = b'0' \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ INNER JOIN mem_level mle on ml.accno = mle.accno and mle.is_delete = b'0' \ \ \ \ \ \ \ where ml.logintype =11 \ \ \ \ \ \ \ \ ORDER BY mb.create_time DESC \ \ \ \ \ \ \ \ LIMIT 1000;    #排序搞不通
    log    ${acclogin_sql}
    ${length2}    get length    ${acclogin_sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${acclogin_sql[${index2}][0]}    ${response1['data']['data'][${index2}]['acclogin']}
    END

试玩账号列表_启用/禁用账号
    comment    获取列表
    ${params}    Create Dictionary    acclogin=    accstatus=    memlevel=    nickname=    uniqueId=    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/trial/trialList    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    comment    接口返回的第一个会员用作下一步骤的参数
    ${acclogin1}    Set Variable    ${response1['data']['data'][0]['acclogin']}
    comment    接口返回的第一个会员的状态
    ${accstatus1}    Set Variable    ${response1['data']['data'][0]['accstatus']}
    COMMENT    执行启用/禁用
    ${params1}    Create Dictionary    acclogin=${acclogin1}
    ${res2}    Post Request    test    manage/trial/updateTrialStatus    params=${params1}    headers=${head}
    ${response2}    to json    ${res2.content}
    comment    断言执行成功
    Should Be Equal As Strings    ${response2['data']['info']}    成功
    COMMENT    在列表中查询该试玩会员的状态已经变动
    ${params2}    Create Dictionary    acclogin=${acclogin1}    accstatus=    memlevel=    nickname=    uniqueId=    pageNo=1    pageSize=10
    ${res3}    get Request    test    manage/trial/trialList    params=${params2}    headers=${head}
    ${response3}    to json    ${res3.content}
    ${accstatus2}    Set Variable    ${response3['data']['data'][0]['accstatus']}
    Should Not Be Equal As Numbers    ${accstatus2}    ${accstatus1}

试玩账号列表_修改密码_成功
    comment    获取列表
    ${params}    Create Dictionary    acclogin=    accstatus=    memlevel=    nickname=    uniqueId=    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/trial/trialList    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    comment    接口返回value作下一步骤的参数
    ${acclogin}    Set Variable    ${response1['data']['data'][0]['acclogin']}
    ${memid}    Set Variable    ${response1['data']['data'][0]['memid']}
    ${uniqueId}    Set Variable    ${response1['data']['data'][0]['uniqueId']}
    ${accno}    Set Variable    ${response1['data']['data'][0]['accno']}
    ${nickname}    Set Variable    ${response1['data']['data'][0]['nickname']}
    ${memlevel}    Set Variable    ${response1['data']['data'][0]['memlevel']}
    ${goldnum}    Set Variable    ${response1['data']['data'][0]['goldnum']}
    ${consumeAmount}    Set Variable    ${response1['data']['data'][0]['consumeAmount']}
    ${noWithdrawalAmount}    Set Variable    ${response1['data']['data'][0]['noWithdrawalAmount']}
    ${clintipadd}    Set Variable    ${response1['data']['data'][0]['clintipadd']}
    ${lastlogindate}    Set Variable    ${response1['data']['data'][0]['lastlogindate']}
    ${online}    Set Variable    ${response1['data']['data'][0]['online']}
    ${accstatus}    Set Variable    ${response1['data']['data'][0]['accstatus']}
    ${remark}    Set Variable    ${response1['data']['data'][0]['remark']}
    ${createUser}    Set Variable    ${response1['data']['data'][0]['createUser']}
    ${createTime}    Set Variable    ${response1['data']['data'][0]['createTime']}
    COMMENT    修改密码
    ${params2}    Create Dictionary    acclogin=${acclogin}    password=${loginid}[2]    surePasWord=${loginid}[2]    memid=${memid}    uniqueId=${uniqueId}    refUniqueId=    accno=${accno}    nickname=${nickname}    memlevel=${memlevel}    goldnum=${goldnum}    consumeAmount=${consumeAmount}    noWithdrawalAmount=${noWithdrawalAmount}    clintipadd=${clintipadd}    lastlogindate=${lastlogindate}    online=${online}
    ...    accstatus=${accstatus}    remark=${remark}    createUser=${createUser}    createTime=${createTime}
    ${res2}    post Request    test    manage/trial/updateTrialPassword    params=${params2}    headers=${head}
    ${response2}    to json    ${res2.content}
    LOG    ${response2}
    Should Be Equal As Strings    ${response2['data']['info']}    成功
    COMMENT    断言使用新密码，可以登陆该试玩账号
    ${params3}    Create Dictionary    password=${loginid}[2]    latitude=131.04925573429551    tel=${acclogin}    longitude=31.315590522490712
    ${res3}    post Request    test    livelogin/app/login    params=${params3}    headers=${head}
    ${response3}    to json    ${res3.content}
    Should Be Equal As Strings    ${response3['info']}    成功

试玩账号列表_修改等级_成功
    comment    获取列表
    ${params}    Create Dictionary    acclogin=    accstatus=    memlevel=    nickname=    uniqueId=    pageNo=1    pageSize=10
    ${res1}    get Request    test    manage/trial/trialList    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    comment    接口返回value作下一步骤的参数
    ${acclogin}    Set Variable    ${response1['data']['data'][0]['acclogin']}
    COMMENT    修改等级
    ${memlevel}    Set Variable    2
    ${params2}    Create Dictionary    acclogin=${acclogin}    memlevel=${memlevel}
    ${res2}    post Request    test    manage/trial/updatelevel    params=${params2}    headers=${head}
    ${response2}    to json    ${res2.content}
    LOG    ${response2}
    Should Be Equal As Strings    ${response2['data']['info']}    成功
    COMMENT    断言该会员的等级为改后等级
    ${params3}    Create Dictionary    acclogin=${acclogin}    accstatus=    memlevel=    nickname=    uniqueId=    pageNo=1    pageSize=10
    ${res3}    get Request    test    manage/trial/trialList    params=${params3}    headers=${head}
    ${response3}    to json    ${res3.content}
    Should Be Equal As Strings    ${memlevel}    ${response3['data']['data'][0]['memlevel']}

试玩账号列表_创建试玩账号_没有删除数据的权限，此用例需每次更新参数
    comment    创建试玩账号
    ${nickname}    Set Variable    创建试玩账号
    ${acclogin}    Set Variable    12388889999
    ${memlevel}    Set Variable    3
    ${params}    Create Dictionary    nickname=${nickname}    acclogin=${acclogin}    password=${loginid}[2]    againPassword=${loginid}[2]    memlevel=${memlevel}
    ${res}    Post Request    test    manage/trial/createAccount    params=${params}    headers=${head}
    ${response1}    to json    ${res.content}
    comment    获取列表    断言列表中包含刚创建的试玩账号
    ${params}    Create Dictionary    acclogin=    accstatus=    memlevel=    nickname=    uniqueId=    pageNo=1    pageSize=1000
    ${res1}    get Request    test    manage/trial/trialList    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    @{accloginList}    Create List
    @{nicknameList}    Create List
    ${length1}    get length    ${response1['data']['data']}
    FOR    ${index1}    IN RANGE    ${length1}
        APPEND TO LIST    ${accloginList}    ${response1['data']['data'][${index1}]['acclogin']}
        APPEND TO LIST    ${nicknameList}    ${response1['data']['data'][${index1}]['nickname']}
    END
    Comment    log    ${accloginList}
    Comment    log    ${nicknameList}
    comment    断言新列表中包含新建数据
    Should Contain    ${accloginList}    ${acclogin}
    Should Contain    ${nicknameList}    ${nickname}
    COMMENT    清除数据
    Execute Sql String    DELETE t1, t2, t3 FROM mem_login t1, mem_baseinfo t2, mem_level t3 WHERE t1.accno = t2.accno AND t2.accno = t3.accno AND t1.acclogin = '${acclogin}';    #慎用

代理报表_查看全部代理
    COMMENT    获取列表
    ${params1}    Create Dictionary    pageNo=1    pageSize=10    searchstr=    type=1
    ${res1}    Get Request    test    manage/agentreport/getAgentList    params=${params1}    headers=${head}
    ${response1}    to json    ${res1.content}
    LOG    ${response1}
    @{nickname}    Create List
    ${length1}    Get Length    ${response1['data']['data']}
    FOR    ${index1}    IN RANGE    ${length1}
        Append To List    ${nickname}    ${response1['data']['data'][${index1}]['nickname']}
    END
    log    ${nickname}
    ${sql}    query    select mb.memid,mb.accno, mb.nickname, mb.recomcode, mb.proxy_url as proxyUrl,(select ifnull(count(*),0) from mem_relationship where refaccno = mb.accno and is_delete = b'0')as memnums,(select truncate(ifnull(sum(reverseamt),0),2) from tra_agentclearing where accno = mb.accno and is_delete = b'0')as reverseamt from mem_baseinfo mb where mb.accno in(select DISTINCT refaccno from mem_relationship) and mb.is_delete = b'0' order by create_time desc limit 10
    ${length2}    Get Length    ${sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${sql[${index2}][2]}    ${response1['data']['data'][${index2}]['nickname']}
    END

代理报表_查看下级会员
    COMMENT    获取列表
    ${params1}    Create Dictionary    pageNo=1    pageSize=10    searchstr=    type=1
    ${res1}    Get Request    test    manage/agentreport/getAgentList    params=${params1}    headers=${head}
    ${response1}    to json    ${res1.content}
    COMMENT    获取代理的accno与昵称
    ${accno}    Set Variable    ${response1['data']['data'][0]['accno']}
    ${pagename}    Set Variable    ${response1['data']['data'][0]['nickname']}
    ${params2}    Create Dictionary    pageNo=1    pageSize=100    searchstr=    accno=${accno}    pagename=${pagename}
    ${res2}    Get Request    test    manage/agentreport/getNextList    params=${params2}    headers=${head}
    ${response2}    to json    ${res2.content}
    @{nicknameList}    Create List
    ${length}    Get Length    ${response2['data']['data']}
    FOR    ${index1}    IN RANGE    ${length}
        Append To List    ${nicknameList}    ${response2['data']['data'][${index1}]['nickname']}
    END
    log    ${nicknameList}
    COMMENT    对比数据库
    ${sql}    query    SELECT t1.relaid,t1.refaccno,t1.accno from mem_relationship t1,mem_baseinfo t2 where t1.accno = t2.accno and \ t1.refaccno = '${accno}' ORDER BY t2.pay_amount desc, t1.create_time ;
    ${length2}    Get Length    ${sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${sql[${index2}][2]}    ${response2['data']['data'][${index2}]['accno']}
    END

代理报表_查看明细
    COMMENT    获取列表
    ${params1}    Create Dictionary    pageNo=1    pageSize=10    searchstr=    type=1
    ${res1}    Get Request    test    manage/agentreport/getAgentList    params=${params1}    headers=${head}
    ${response1}    to json    ${res1.content}
    COMMENT    获取代理的accno
    ${accno}    Set Variable    ${response1['data']['data'][0]['accno']}
    ${params2}    Create Dictionary    pageNo=1    pageSize=1000    accno=${accno}    datesta=
    ${res2}    Get Request    test    manage/agentreport/getDetail    params=${params2}    headers=${head}
    ${response2}    to json    ${res2.content}
    ${length1}    get length    ${response2['data']['data']}
    @{cleanid}    Create List
    FOR    ${index1}    IN RANGE    ${length1}
        Append To List    ${cleanid}    ${response2['data']['data'][${index1}]['cleanid']}
    END
    log    ${cleanid}
    COMMENT    对比库中数据
    ${sql}    query    select ta.cleanid from tra_agentclearing ta left join sys_agentinfo sa on ta.agentid = sa.agentid where ta.accno = '660d05f5fe944c929d713331598b6957' and ta.is_delete = b'0' order by ta.create_time desc
    ${length2}    get length    ${sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${sql[${index2}][0]}    ${response2['data']['data'][${index2}]['cleanid']}
    END

代理设置列表
    COMMENT    获取列表
    ${params1}    Create Dictionary    pageNo=1    pageSize=10    searchstr=
    ${res1}    Get Request    test    manage/agent/getList    params=${params1}    headers=${head}
    ${response1}    to json    ${res1.content}
    ${length1}    get length    ${response1['data']['data']}
    @{agentname}    Create List
    @{agentid}    Create List
    FOR    ${index1}    IN RANGE    ${length1}
        Append To List    ${agentname}    ${response1['data']['data'][${index1}]['agentname']}
        Append To List    ${agentid}    ${response1['data']['data'][${index1}]['agentid']}
    END
    COMMENT    对比库中数据
    ${sql}    query    SELECT * from sys_agentinfo t where t.is_delete = 0 ORDER BY t.sortby desc
    ${length2}    get length    ${sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${sql[${index2}][0]}    ${response1['data']['data'][${index2}]['agentid']}
        Should Be Equal As Strings    ${sql[${index2}][1]}    ${response1['data']['data'][${index2}]['agentname']}
    END

代理设置列表_检索名称
    COMMENT    获取列表
    ${var}    Set Variable    2
    ${params1}    Create Dictionary    pageNo=1    pageSize=10    searchstr=${var}
    ${res1}    Get Request    test    manage/agent/getList    params=${params1}    headers=${head}
    ${response1}    to json    ${res1.content}
    ${length1}    get length    ${response1['data']['data']}
    @{agentname}    Create List
    @{agentid}    Create List
    FOR    ${index1}    IN RANGE    ${length1}
        Append To List    ${agentname}    ${response1['data']['data'][${index1}]['agentname']}
        Append To List    ${agentid}    ${response1['data']['data'][${index1}]['agentid']}
    END
    COMMENT    对比库中数据
    ${sql}    query    SELECT * from sys_agentinfo t where t.is_delete = 0 and t.agentname like '%${var}%' ORDER BY t.sortby desc
    ${length2}    get length    ${sql}
    FOR    ${index2}    IN RANGE    ${length2}
        Should Be Equal As Strings    ${sql[${index2}][0]}    ${response1['data']['data'][${index2}]['agentid']}
        Should Be Equal As Strings    ${sql[${index2}][1]}    ${response1['data']['data'][${index2}]['agentname']}
    END

代理设置列表_新建代理设置
    COMMENT    断言列表中暂时没有即将创建的代理设置
    ${var}    Set Variable    新建代理设置
    ${params1}    Create Dictionary    pageNo=1    pageSize=10    searchstr=${var}
    ${res1}    Get Request    test    manage/agent/getList    params=${params1}    headers=${head}
    ${response1}    to json    ${res1.content}
    COMMENT    断言查询结果为空
    Should Be Equal As Strings    ${response1['data']['totalCount']}    0
    COMMENT    创建
    ${params2}    Create Dictionary    agentname=${var}    minamt=100    maxamt=2000    commission=5    sortby=99
    ${res2}    Post Request    test    manage/agent/doAdd    params=${params2}    headers=${head}
    ${response2}    to json    ${res2.content}
    Should Be Equal As Strings    ${response2['info']}    成功
    COMMENT    获取列表，并断言能查询到刚创建的代理设置 \
    ${params3}    Create Dictionary    pageNo=1    pageSize=10    searchstr=${var}
    ${res3}    Get Request    test    manage/agent/getList    params=${params3}    headers=${head}
    ${response3}    to json    ${res3.content}
    Should Not Be Equal As Strings    ${response3['data']['totalCount']}    0
    ${agentid}    Set Variable    ${response3['data']['data'][0]['agentid']}
    [Teardown]    接口_删除代理设置

代理设置列表_编辑代理设置
    [Setup]    接口_新建代理设置
    COMMENT    获取agentid
    ${var1}    Set Variable    新建代理设置
    ${params3}    Create Dictionary    pageNo=1    pageSize=10    searchstr=${var1}
    ${res3}    Get Request    test    manage/agent/getList    params=${params3}    headers=${head}
    ${response3}    to json    ${res3.content}
    ${agentid}    Set Variable    ${response3['data']['data'][0]['agentid']}
    ${var2}    Set Variable    编辑代理设置
    ${params1}    Create Dictionary    agentid=${agentid}    agentname=${var2}    minamt=100    maxamt=2000    commission=0.1    sortby=99
    ${res1}    Post Request    test    manage/agent/doEdt    params=${params1}    headers=${head}
    COMMENT    断言编辑后，列表中只有编辑后的数据
    ${params2}    Create Dictionary    pageNo=1    pageSize=10    searchstr=
    ${res2}    Get Request    test    manage/agent/getList    params=${params2}    headers=${head}
    ${response2}    to json    ${res2.content}
    ${length1}    get length    ${response2['data']['data']}
    @{agentname}    Create List
    FOR    ${index1}    IN RANGE    ${length1}
        Append To List    ${agentname}    ${response2['data']['data'][${index1}]['agentname']}
    END
    Should Contain    ${agentname}    ${var2}
    Should Not Contain    ${agentname}    ${var1}
    [Teardown]    接口_删除代理设置

代理设置列表_删除代理设置
    [Setup]    接口_新建代理设置
    COMMENT    获取agentid
    ${var1}    Set Variable    新建代理设置
    ${params3}    Create Dictionary    pageNo=1    pageSize=10    searchstr=${var1}
    ${res3}    Get Request    test    manage/agent/getList    params=${params3}    headers=${head}
    ${response3}    to json    ${res3.content}
    ${agentid}    Set Variable    ${response3['data']['data'][0]['agentid']}
    Comment    ${var1}    Set Variable    新建代理设置
    Comment    ${var2}    Set Variable    编辑代理设置
    ${sql}    query    SELECT t.agentid from sys_agentinfo t where t.is_delete = 0 and t.agentname = '${var1}';
    Comment    ${agentid}    Set Variable    ${sql[0][0]}
    ${params}    Create Dictionary    agentid=${agentid}
    ${res}    Get Request    test    manage/agent/doDel    params=${params}    headers=${head}
    ${res1}    to json    ${res.content}
    Should Be Equal As Strings    ${res1['info']}    成功
    [Teardown]    接口_删除代理设置

会员状态管理_全局禁言
    ${params}    create dictionary    pageNo=1    pageSize=100    uniqueId=    roomname=    type=1\,2
    ${res1}    post request    test    live/anchor/getMemInfoStatusList    params=${params}    headers=${head}
    ${response1}    to json    ${res1.content}
    log    ${response1}
    ${length1}    get length    ${response1['data']['data']}
    Comment    @{idList1}    create list
    Comment    FOR    ${index1}    IN RANGE    ${length1}
    Comment    \    append to list    ${idList1}    ${response1['data']['data'][${index1}]['id']}
    Comment    END
    Comment    log    ${idList1}
    Comment    ${id_sql}    query    select t.id from mem_level_config t where t.is_delete = 0 order by t.recharge_amount desc limit 100
    Comment    ${length2}    get length    ${id_sql}
    Comment    should be equal as strings    ${length1}    ${length2}    #断言个数相同
    Comment    FOR    ${index2}    IN RANGE    ${length2}
    Comment    \    ${idList2}    set variable    ${id_sql[${index2}][0]}
    Comment    \    log    ${idList2}
    Comment    \    Should Be Equal As Strings    ${idList2}    ${idList1[${index2}]}
    Comment    END
