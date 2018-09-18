[dsclocalconfigurationmanager()]
configuration lcm {
    Settings {
        RefreshMode = 'Pull'
        RebootNodeIfNeeded = $true
        ActionAfterReboot = 'ContinueConfiguration'
        ConfigurationMode = 'ApplyAndAutoCorrect'
        RefreshFrequencyMins = 30 # interval pull server check (default and minimum is 30)
        ConfigurationModeFrequencyMins = 15 # interval consitency check (default 15)
    }

    ConfigurationRepositoryWeb SQLPullWeb {
        ServerURL = 'http://wspull:8080/PSDSCPullServer.svc'
        RegistrationKey = 'cb30127b-4b66-4f83-b207-c4801fb05087'
        AllowUnsecureConnection = $true
        ConfigurationNames = 'baseConfig' 
    }

    ResourceRepositoryWeb SQLPullWeb {
        ServerURL = 'http://wspull:8080/PSDSCPullServer.svc'
        RegistrationKey = 'cb30127b-4b66-4f83-b207-c4801fb05087'
        AllowUnsecureConnection = $true
    }

    ReportServerWeb SQLPullWeb {
        ServerURL = 'http://wspull:8080/PSDSCPullServer.svc'
        RegistrationKey = 'cb30127b-4b66-4f83-b207-c4801fb05087'
        AllowUnsecureConnection = $true
    }
}
lcm

Set-DscLocalConfigurationManager .\lcm -Verbose -Force