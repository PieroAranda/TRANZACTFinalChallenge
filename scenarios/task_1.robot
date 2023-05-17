*** Settings ***
Resource    ../load_resource.resource
Test Teardown    Close Browser


*** Test Cases ***

Task 1
    [Tags]    task_1
    Open Browser    ${EVERSHOP_URL}    chrome
    Click Element    xpath://a[@href='/account/login']
    Click Element    xpath://a[@href='/account/register']
    Generate Random Data for Customer
    Fill Create New Account Form
    Wait Until Element Is Visible    xpath://h2[text()='Discount 20% For All Orders Over $2000']
    Capture Page Screenshot
    Select a Product from Each Category
    Click Element    xpath:(//a[@href='/cart'])[2]
    Wait Until Element Is Visible    xpath://h4[text()='Order summary']
    Capture Page Screenshot
    Click Element    xpath://a[@href='/checkout']
    Wait Until Element Is Visible    xpath://h4[text()='Shipping Address']
    Capture Page Screenshot
    Fill Shipping Form
    Wait Until Element Is Visible    xpath://h4[text()='Payment Method']
    Capture Page Screenshot
    Fill Payment Method
    Wait Until Element Is Visible    xpath://div[contains(text(),'Thank you')]
    Capture Page Screenshot
    Verify Order was registered correctly


Task 2_1
    [Tags]    task_2_1
    ${i}=    Set Variable    0    
    FOR  ${code}  IN  @{COUNTRIES_CODE}
        ${response}=    GET    ${BASE_URL}/alpha/${code}    params=access_key=${ACCESS_KEY}    expected_status=200
        ${response}=    Set Variable    ${response.json()}
        Log    ${response}
        Should Be Equal    ${response}[name]    ${COUNTRIES}[${i}]
        ${i}=    Evaluate    ${i} + 1
    END


Task 2_2
    [Tags]    task_2_2  
    FOR  ${code}  IN  @{UNEXISTING_CODE}
        ${response}=    GET    ${BASE_URL}/alpha/${code}    params=access_key=${ACCESS_KEY}    expected_status=404
        ${response}=    Set Variable    ${response.json()}
        Log    ${response}
        Should Be Equal    ${response}[message]    Not Found
    END


Task 2_3
    [Tags]    task_2_3  
    ${json_data}=    Create Dictionary    name=Test Country    alpha2_code=TC    alpha3_code=TCY
    ${response}=    POST    ${BASE_URL}/add    params=access_key=${ACCESS_KEY}    json=${json_data}
    ${response}=    Set Variable    ${response.json()}
    Log    ${response}
    Should Be Equal    ${response}[status]    Successful