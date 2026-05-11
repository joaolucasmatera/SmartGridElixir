defmodule SmartGridElixir.ValidatorTest do
  use ExUnit.Case
  
  alias SmartGridElixir.{Reading, Validator}

  doctest Validator

  describe "remover_outliers/1" do
    test "retorna lista vazia para entrada vazia" do
      {leituras, removidas} = Validator.remover_outliers([])
      assert leituras == []
      assert removidas == 0
    end

    test "remove leituras com kwh inválido (≤ 0)" do
      leituras = [
        %Reading{consumer_id: "C1", kwh: 0, timestamp: DateTime.utc_now()},
        %Reading{consumer_id: "C2", kwh: 100, timestamp: DateTime.utc_now()},
        %Reading{consumer_id: "C3", kwh: -50, timestamp: DateTime.utc_now()}
      ]

      {validas, removidas} = Validator.remover_outliers(leituras)
      
      assert length(validas) == 1
      assert removidas == 2
      assert hd(validas).kwh == 100
    end

    test "remove outliers com Z-score > 3" do
      leituras = [
        %Reading{consumer_id: "C1", kwh: 100, timestamp: DateTime.utc_now()},
        %Reading{consumer_id: "C2", kwh: 105, timestamp: DateTime.utc_now()},
        %Reading{consumer_id: "C3", kwh: 103, timestamp: DateTime.utc_now()},
        %Reading{consumer_id: "C4", kwh: 999, timestamp: DateTime.utc_now()}  # Outlier
      ]

      {validas, removidas} = Validator.remover_outliers(leituras)
      
      assert length(validas) == 3
      assert removidas == 1
      assert Enum.all?(validas, &(&1.kwh < 200))
    end

    test "calcula Z-score corretamente" do
      media = 100.0
      desvio = 10.0
      
      # Valor na média: Z-score = 0
      assert Validator.calcular_z_score(100.0, media, desvio) == 0.0
      
      # Valor 1 desvio acima: Z-score = 1
      assert Validator.calcular_z_score(110.0, media, desvio) == 1.0
      
      # Valor 3 desvios acima: Z-score = 3
      assert Validator.calcular_z_score(130.0, media, desvio) == 3.0
    end

    test "calcula média corretamente" do
      leituras = [
        %Reading{kwh: 100},
        %Reading{kwh: 200},
        %Reading{kwh: 300}
      ]

      media = Validator.calcular_media(leituras)
      assert media == 200.0
    end

    test "calcula desvio padrão corretamente" do
      leituras = [
        %Reading{kwh: 100},
        %Reading{kwh: 200},
        %Reading{kwh: 300}
      ]

      desvio = Validator.calcular_desvio_padrao(leituras, 200.0)
      assert Float.round(desvio, 2) == 81.65
    end
  end
end
