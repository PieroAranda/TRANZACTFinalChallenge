*** Settings ***
Resource    ../../load_resource.resource


*** Keywords ***
Verify Shipping / Billing Address
    FOR  ${i}  IN RANGE    2                            #One Iteration For Shipping and One Iteration For Billing
        ${i}=    Evaluate    ${i} + 1
        ${actual_full_name}=    Get Text    xpath:(//div[@class='full-name'])[${i}]
        Should Be Equal    ${actual_full_name}    ${customer_data}[full_name]
        ${actual_address}=    Get Text    xpath:(//div[@class='address-one'])[${i}]
        Should Be Equal    ${actual_address}    ${customer_data}[address_1]
        ${actual_postcode}=    Get Text    xpath:(//div[@class='city-province-postcode'])[${i}]/div[1]
        ${actual_postcode}=    Split String    ${actual_postcode}    ,
        ${actual_postcode}=    Set Variable    ${actual_postcode}[0]
        Should Be Equal    ${actual_postcode}    ${customer_data}[postcode]
        ${actual_province}=    Get Text    xpath:(//div[@class='city-province-postcode'])[${i}]/div[2]
        ${actual_province}=    Split String    ${actual_province}    , 
        ${actual_country}=    Set Variable    ${actual_province}[1]
        ${actual_province}=    Set Variable    ${actual_province}[0]
        Should Be Equal    ${actual_province}    ${customer_data}[province]
        ${actual_country}=    Get Substring   ${actual_country}    1
        Should Be Equal    ${actual_country}    ${customer_data}[country]
        ${actual_telephone}=    Get Text    xpath:(//div[@class='telephone'])[${i}]
        Should Be Equal    ${actual_telephone}    ${customer_data}[telephone]
    END


Verify Order's Items
    ${items}=    Set Variable    ${cart}[items]
    ${i}=    Set Variable    1
    FOR  ${item}  IN  @{items}
        ${actual_item_name}=    Get Text    xpath:((//div[@class='product-column'])[${i}]//span)[1]
        ${actual_item_name}=    Convert To Lower Case    ${actual_item_name}
        Should Be Equal    ${actual_item_name}    ${item}[name]
        ${actual_item_size}=    Get Text    xpath:((//div[@class='product-column'])[${i}]//span)[3]
        ${actual_item_size}=    Convert To Lower Case    ${actual_item_size}
        Should Be Equal    ${actual_item_size}    ${item}[size]
        ${actual_item_color}=    Get Text    xpath:((//div[@class='product-column'])[${i}]//span)[5]
        ${actual_item_color}=    Convert To Lower Case    ${actual_item_color}
        Should Be Equal    ${actual_item_color}    ${item}[color]
        ${actual_item_price}=    Get Text    xpath:((//div[@class='product-column'])[${i}]/parent::td)[1]/following-sibling::td/span
        ${actual_item_price}=    Get Substring    ${actual_item_price}    1
        ${actual_item_price}=     Convert To Number    ${actual_item_price}
        Should Be Equal    ${actual_item_price}    ${item}[price]
        ${i}=    Evaluate    ${i} + 1
    END
    ${actual_subtotal}=    Get Text    xpath:((//div[@class='summary-row'])[1]//div)[3]
    ${actual_subtotal}=    Get Substring    ${actual_subtotal}    1
    ${actual_subtotal}=     Convert To Number    ${actual_subtotal}
    Should Be Equal    ${actual_subtotal}    ${cart}[subtotal]
    ${actual_shipping_method}=    Get Text    xpath:((//div[@class='summary-row'])[2]//div)[3]
    ${actual_shipping_method}=    Get Substring    ${actual_shipping_method}    1
    ${actual_shipping_method}=     Convert To Number    ${actual_shipping_method}
    Should Be Equal    ${actual_shipping_method}    ${cart}[shipping_method]
    ${actual_total}=    Get Text    xpath://div[@class='grand-total-value']
    ${actual_total}=    Get Substring    ${actual_total}    1
    ${actual_total}=     Convert To Number    ${actual_total}
    Should Be Equal    ${actual_total}    ${cart}[total]


Verify Order was registered correctly
    ${actual_contact_email}=    Get Text    xpath://div[text()='Contact information']/following-sibling::div
    Should Be Equal    ${actual_contact_email}    ${customer_data}[email]
    ${actual_payment_method}=    Get Text    xpath://div[text()='Payment Method']/following-sibling::div
    Should Be Equal    ${actual_payment_method}    Credit Card
    Verify Shipping / Billing Address
    Verify Order's Items