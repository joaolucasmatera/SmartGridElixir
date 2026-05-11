defmodule SmartGridElixir.TarifaTest do
  use ExUnit.Case

  alias SmartGridElixir.{Reading, Tarifa}

  doctest Tarifa

  describe "calcular/2" do
    test "calcula tarifa residencial com bandeira verde" do
      reading = %Reading{
        consumer_id: "C1",
        kwh: 100,
        profile: :residencial,
        timestamp: DateTime.utc_now()
      }

      valor = Tarifa.calcular(reading, :verde)
      # 100 kwh * 0.72 (residencial) * 1.00 (verde) = 72.00
      assert Float.round(valor, 2) == 72.00
    end

    test "calcula tarifa residencial com bandeira amarela" do
      reading = %Reading{
        consumer_id: "C1",
        kwh: 100,
        profile: :residencial,
        timestamp: DateTime.utc_now()
      }

      valor = Tarifa.calcular(reading, :amarela)
      # 100 kwh * 0.72 * 1.021 = 73.512
      assert Float.round(valor, 3) == 73.512
    end

    test "calcula tarifa residencial com bandeira vermelha" do
      reading = %Reading{
        consumer_id: "C1",
        kwh: 100,
        profile: :residencial,
        timestamp: DateTime.utc_now()
      }

      valor = Tarifa.calcular(reading, :vermelha)
      # 100 kwh * 0.72 * 1.040 = 74.88
      assert Float.round(valor, 2) == 74.88
    end

    test "calcula tarifa comercial" do
      reading = %Reading{
        consumer_id: "C1",
        kwh: 100,
        profile: :comercial,
        timestamp: DateTime.utc_now()
      }

      valor = Tarifa.calcular(reading, :verde)
      # 100 kwh * 0.85 * 1.00 = 85.00
      assert Float.round(valor, 2) == 85.00
    end

    test "calcula tarifa industrial" do
      reading = %Reading{
        consumer_id: "C1",
        kwh: 100,
        profile: :industrial,
        timestamp: DateTime.utc_now()
      }

      valor = Tarifa.calcular(reading, :verde)
      # 100 kwh * 0.62 * 1.00 = 62.00
      assert Float.round(valor, 2) == 62.00
    end

    test "aplica desconto de 5% para consumo > 500 kWh" do
      reading = %Reading{
        consumer_id: "C1",
        kwh: 600,
        profile: :industrial,
        timestamp: DateTime.utc_now()
      }

      valor = Tarifa.calcular(reading, :verde)
      # 600 kwh * 0.62 * 1.00 * 0.95 (desconto) = 354.6
      assert Float.round(valor, 1) == 354.6
    end

    test "não aplica desconto para consumo ≤ 500 kWh" do
      reading = %Reading{
        consumer_id: "C1",
        kwh: 500,
        profile: :industrial,
        timestamp: DateTime.utc_now()
      }

      valor = Tarifa.calcular(reading, :verde)
      # 500 kwh * 0.62 * 1.00 = 310.0 (sem desconto)
      assert Float.round(valor, 2) == 310.0
    end
  end

  describe "multiplicador/1" do
    test "retorna multiplicador correto para bandeira verde" do
      assert Tarifa.multiplicador(:verde) == 1.00
    end

    test "retorna multiplicador correto para bandeira amarela" do
      assert Tarifa.multiplicador(:amarela) == 1.021
    end

    test "retorna multiplicador correto para bandeira vermelha" do
      assert Tarifa.multiplicador(:vermelha) == 1.040
    end
  end

  describe "tarifa_base/1" do
    test "retorna tarifa base para perfil residencial" do
      assert Tarifa.tarifa_base(:residencial) == 0.72
    end

    test "retorna tarifa base para perfil comercial" do
      assert Tarifa.tarifa_base(:comercial) == 0.85
    end

    test "retorna tarifa base para perfil industrial" do
      assert Tarifa.tarifa_base(:industrial) == 0.62
    end
  end
end
