ExUnit.start()

Application.put_env(:assistant, :hex_pm_client, Assistant.HexPm.MockClient)
