*** Settings ***
#Libraries
Library    SeleniumLibrary
Library    String
Library    Collections
Library    BuiltIn
Library    RequestsLibrary
Library    JSONLibrary


#Resources
Resource    resources/Main/Common.resource
Resource    resources/Main/Validate.resource


#Variables
Variables   config.yml