input {
        # pg_stat_database
        jdbc {
                jdbc_driver_library => ""
                jdbc_driver_class => "org.postgresql.Driver"
                jdbc_connection_string => "jdbc:postgresql://${host}:${port}/ibmclouddb"
                jdbc_user => "admin"
                jdbc_password => "${psg_password}"
                statement => "SELECT * FROM pg_stat_database"
                schedule => "* * * * *"
                type => "pg_stat_database"
        }

        # pg_stat_user_tables
        jdbc {
                jdbc_driver_library => ""
                jdbc_driver_class => "org.postgresql.Driver"
                jdbc_connection_string => "jdbc:postgresql://${host}:${port}/ibmclouddb"
                jdbc_user => "admin"
                jdbc_password => "${psg_password}"
                statement => "SELECT * FROM pg_stat_user_tables"
                schedule => "* * * * *"
                type => "pg_stat_user_tables"
        }

        # pg_stat_user_indexes
        jdbc {
                jdbc_driver_library => ""
                jdbc_driver_class => "org.postgresql.Driver"
                jdbc_connection_string => "jdbc:postgresql://${host}:${port}/ibmclouddb"
                jdbc_user => "admin"
                jdbc_password => "${psg_password}"
                statement => "SELECT * FROM pg_stat_user_indexes"
                schedule => "* * * * *"
                type => "pg_stat_user_indexes"
        }
}

output {
        elasticsearch {
                hosts => "http://localhost:9200"
                index => "%{type}"
        }
}
