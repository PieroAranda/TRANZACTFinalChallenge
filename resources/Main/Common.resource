*** Settings ***
Resource    ../../load_resource.resource


*** Keywords ***
Generate Random Data for Customer
    ${random_first_name}=    Generate Random String    5    [LETTERS]
    ${random_last_name}=    Generate Random String    5    [LETTERS]
    ${random_full_name}=    Set Variable    ${random_first_name} ${random_last_name}
    ${random_email}=    Generate Random String    10    [LETTERS]
    ${random_email}=    Set Variable    ${random_email}@hotmail.com
    ${random_password}=    Generate Random String    10    [LETTERS]
    ${random_telephone}=    Generate Random String    10    [NUMBERS]
    ${random_address}=    Generate Random String    15    [LETTERS]
    ${random_city}=    Generate Random String    10    [LETTERS]
    ${customer_data}=    Create Dictionary    full_name=${random_full_name}    email=${random_email}    password=${random_password}    
    ...    telephone=${random_telephone}    address_1=${random_address}    city=${random_city}
    Set Global Variable    ${customer_data}


Fill Create New Account Form
    Input Text    xpath://input[@name='full_name']    ${customer_data}[full_name]
    Input Text    xpath://input[@name='email']    ${customer_data}[email]
    Input Password    xpath://input[@name='password']    ${customer_data}[password]
    Click Button    xpath://button[@type='button']


Select a Product from Each Category
    ${lista_items}=    Evaluate    []
    ${subtotal}=    Set Variable    0
    ${selenium_speed}=    Set Selenium Speed    0.5 seconds
    FOR  ${category}  IN  @{CATEGORIES}
        Click Element    xpath:(//a[@href='/category/${category}'])[1]
        Click Element    xpath:((//div[@class='listing-tem'])[1])/div[1]/a
        ${item_name}=    Get Text    xpath://h1[@class='product-single-name']
        ${item_name}=    Convert To Lower Case    ${item_name}
        Click Element    xpath:((//form/following-sibling::div[1]//ul)[1]//a)[1]
        ${item_size}=    Get Text    xpath:((//form/following-sibling::div[1]//ul)[1]//a)[1]
        ${item_size}=    Convert To Lower Case    ${item_size}
        Click Element    xpath:((//form/following-sibling::div[1]//ul)[2]//a)[1]
        ${item_color}=    Get Text    xpath:((//form/following-sibling::div[1]//ul)[2]//a)[1]
        ${item_color}=    Convert To Lower Case    ${item_color}
        ${item_price}=    Get Text    xpath://span[@class='sale-price']
        ${item_price}=    Get Substring    ${item_price}    1
        ${item_price}=    Convert To Number    ${item_price}
        ${subtotal}=    Evaluate    ${subtotal} + ${item_price}
        ${items}=    Create Dictionary    name=${item_name}    size=${item_size}    color=${item_color}    price=${item_price}
        Append To List    ${lista_items}    ${items}
        Click Element    xpath://button
        Wait Until Element Is Visible    xpath://div[@role='alert']
        Capture Page Screenshot
    END
    Set Selenium Speed    ${selenium_speed}
    ${cart}=    Create Dictionary    items=${lista_items}    subtotal=${subtotal}
    Set Global Variable    ${cart}


Fill Shipping Form
    ${keys}=    Evaluate    ${customer_data}.keys()  
    FOR  ${key}  IN  @{keys}
        IF  "${key}" != "email" and "${key}" != "password"
           Input Text    xpath://input[@name='address[${key}]']    ${customer_data}[${key}] 
        END
    END
    ${selenium_speed}=    Set Selenium Speed    0.5 seconds
    ${country_options_amount}=    Get Element Count    xpath://select[@name='address[country]']/option
    ${random_country_index}=    Evaluate    random.randint(2,${country_options_amount} - 1)            #not considering Algeria since there is no available method for any address
    Select From List By Index    xpath://select[@name='address[country]']    ${random_country_index}
    ${selected_country}=    Get Selected List Label    xpath://select[@name='address[country]']
    ${province_options_amount}=    Get Element Count    xpath://select[@name='address[province]']/option
    ${random_province_index}=    Evaluate    random.randint(1,${province_options_amount} - 1)
    Select From List By Index    xpath://select[@name='address[province]']    ${random_country_index}
    ${selected_province}=    Get Selected List Label    xpath://select[@name='address[province]']
    ${random_postcode}=    Generate Random String   5    [NUMBERS]
    Input Text    xpath://input[@name='address[postcode]']    ${random_postcode}
    Wait Until Element Is Not Visible    xpath://div[contains(text(),'enter a shipping address')]
    ${shipping_method_options_amount}=    Get Element Count    xpath://input[@type='radio']
    ${random_shipping_method_index}=    Evaluate    random.randint(0,${shipping_method_options_amount} - 1)
    Click Element    xpath://input[@id='method${random_shipping_method_index}']/following-sibling::span[1]
    ${selected_shipping_method}=    Get Text    xpath://input[@id='method${random_shipping_method_index}']/following-sibling::span[2]
    ${selected_shipping_method}=    Split String   ${selected_shipping_method}    - $
    ${selected_shipping_method}=    Set Variable    ${selected_shipping_method}[1]
    ${selected_shipping_method}=    Convert To Number    ${selected_shipping_method}
    Set Selenium Speed    ${selenium_speed}
    ${total}=    Evaluate    ${cart}[subtotal] + ${selected_shipping_method}
    Set To Dictionary    ${customer_data}    country    ${selected_country}    province    ${selected_province}    
    ...    postcode    ${random_postcode}
    Set To Dictionary    ${cart}    shipping_method    ${selected_shipping_method}    total    ${total}
    Capture Page Screenshot
    Click Button    xpath://button[@type='button']


Fill Payment Method
    ${selenium_speed}=    Set Selenium Speed    0.5 seconds
    Click Element    xpath:(//h4[text()='Payment Method']/following-sibling::div[1])/div[3]//a
    Click Button   xpath://span[text()='Test success']/parent::button
    Set Selenium Speed    ${selenium_speed}
    ${card_number}=    Get Text    xpath://div[contains(text(),'Test card number')]
    ${card_number}=    Split String    ${card_number}    number: 
    ${card_number}=    Set Variable    ${card_number}[1]
    ${card_expiry}=    Get Text    xpath://div[contains(text(),'Test card expiry')]
    ${card_expiry}=    Split String    ${card_expiry}    expiry: 
    ${card_expiry}=    Set Variable    ${card_expiry}[1]
    ${card_cvc}=    Get Text    xpath://div[contains(text(),'Test card CVC')]
    ${card_cvc}=    Split String    ${card_cvc}    CVC: 
    ${card_cvc}=    Set Variable    ${card_cvc}[1]
    Select Frame    xpath://div[@id='card-element']//iframe
    Input Text    xpath://input[@name='cardnumber']    ${card_number}
    Input Text    xpath://input[@name='exp-date']    ${card_expiry}
    Input Text    xpath://input[@name='cvc']    ${card_cvc}
    Unselect Frame
    Capture Page Screenshot
    Click Element    xpath://span[text()='Place Order']