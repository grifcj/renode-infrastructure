# emul8: ignore test

*** Settings ***
Library         String
Library         Process
Library         OperatingSystem
Library         helper.py

*** Variables ***
${SERVER_REMOTE_DEBUG}    False
${SERVER_REMOTE_PORT}     12345
${SERVER_REMOTE_SUSPEND}  y 
${SKIP_RUNNING_SERVER}    False
${CONFIGURATION}          Release
${PORT_NUMBER}            9999
${DIRECTORY}              ${CURDIR}/../output/${CONFIGURATION}
${BINARY_NAME}            ./RobotFrontend.exe
${HOTSPOT_ACTION}         None

*** Keywords ***
Setup
    ${CONFIGURATION}=  Set Variable If  not ${SKIP_RUNNING_SERVER} and ${SERVER_REMOTE_DEBUG}  
    ...    Debug  
    ...    ${CONFIGURATION}

    File Should Exist    ${DIRECTORY}/${BINARY_NAME}  msg=Robot Frontend binary not found. Did you forget to build it in ${CONFIGURATION} configuration?

    Run Keyword If       not ${SKIP_RUNNING_SERVER} and not ${SERVER_REMOTE_DEBUG}
    ...   Start Process  mono  ${BINARY_NAME}  ${PORT_NUMBER}  cwd=${DIRECTORY}

    Run Keyword If       not ${SKIP_RUNNING_SERVER} and ${SERVER_REMOTE_DEBUG}
    ...   Start Process  mono
          ...            --debug
          ...            --debugger-agent\=transport\=dt_socket,address\=0.0.0.0:${SERVER_REMOTE_PORT},server\=y,suspend\=${SERVER_REMOTE_SUSPEND}
          ...            ${BINARY_NAME}  ${PORT_NUMBER}  cwd=${DIRECTORY}

    Wait Until Keyword Succeeds  60s  1s
    ...   Import Library  Remote  http://localhost:${PORT_NUMBER}/

    Reset Emulation

Teardown
    Run Keyword Unless  ${SKIP_RUNNING_SERVER}
    ...   Stop Remote Server

    Run Keyword Unless  ${SKIP_RUNNING_SERVER}
    ...   Wait For Process

Hot Spot
    Handle Hot Spot  ${HOTSPOT_ACTION}
