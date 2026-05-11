defmodule SmartGrid.PipelineTest do
  use ExUnit.Case

  alias SmartGrid.{Reading, Invoice, Pipeline}

  doctest Pipeline

  describe "process/2" do
    test "processa leituras simples e gera invoice" do
      leituras = [
        %Reading{
          consumer_id: "C1",
          kwh: 100,
          profile: :residencial,
          timestamp: DateTime.utc_now()
        },
        %Reading{
          consumer_id: "C1",
          kwh: 105,
          profile: :residencial,
          timestamp: DateTime.utc_now()
        }
      ]

      invoice = Pipeline.process(leituras, :verde)

      assert %Invoice{} = invoice
      assert invoice.bandeira == :verde
      assert invoice.consumo_kwh == 205.0
      assert Float.round(invoice.total, 2) == 147.6  # 205 * 0.72
    end

    test "remove outliers no pipeline" do
      leituras = [
        %Reading{
          consumer_id: "C1",
          kwh: 100,
          profile: :residencial,
          timestamp: DateTime.utc_now()
        },
        %Reading{
          consumer_id: "C1",
          kwh: 105,
          profile: :residencial,
          timestamp: DateTime.utc_now()
        },
        %Reading{
          consumer_id: "C1",
          kwh: 999,
          profile: :residencial,
          timestamp: DateTime.utc_now()
        }
      ]

      invoice = Pipeline.process(leituras, :verde)

      assert invoice.outliers_removidos >= 1
      assert invoice.consumo_kwh < 250  # Não incluiu o outlier de 999
    end

    test "processa com bandeira amarela" do
      leituras = [
        %Reading{
          consumer_id: "C1",
          kwh: 100,
          profile: :residencial,
          timestamp: DateTime.utc_now()
        }
      ]

      invoice = Pipeline.process(leituras, :amarela)

      assert invoice.bandeira == :amarela
      # 100 * 0.72 * 1.021 = 73.512
      assert Float.round(invoice.total, 3) == 73.512
    end

    test "processa com bandeira vermelha" do
      leituras = [
        %Reading{
          consumer_id: "C1",
          kwh: 100,
          profile: :residencial,
          timestamp: DateTime.utc_now()
        }
      ]

      invoice = Pipeline.process(leituras, :vermelha)

      assert invoice.bandeira == :vermelha
      # 100 * 0.72 * 1.040 = 74.88
      assert Float.round(invoice.total, 2) == 74.88
    end

    test "processa com diferentes perfis" do
      leituras_residencial = [
        %Reading{
          consumer_id: "C1",
          kwh: 100,
          profile: :residencial,
          timestamp: DateTime.utc_now()
        }
      ]

      leituras_comercial = [
        %Reading{
          consumer_id: "C1",
          kwh: 100,
          profile: :comercial,
          timestamp: DateTime.utc_now()
        }
      ]

      invoice_res = Pipeline.process(leituras_residencial, :verde)
      invoice_com = Pipeline.process(leituras_comercial, :verde)

      # Comercial (0.85) deve ser mais caro que residencial (0.72)
      assert invoice_com.total > invoice_res.total
    end

    test "retorna 0 para lista vazia" do
      invoice = Pipeline.process([], :verde)

      assert invoice.total == 0
      assert invoice.consumo_kwh == 0.0
    end
  end

  describe "process_with_details/2" do
    test "retorna mapa com detalhes da execução" do
      leituras = [
        %Reading{
          consumer_id: "C1",
          kwh: 100,
          profile: :residencial,
          timestamp: DateTime.utc_now()
        }
      ]

      resultado = Pipeline.process_with_details(leituras, :verde)

      assert %{
        invoice: %Invoice{},
        total_leituras: 1,
        leituras_validas: 1,
        outliers_removidos: 0,
        consumo_kwh: 100.0,
        valores_por_leitura: [_],
        tempo_processamento_ms: tempo,
        bandeira: :verde
      } = resultado

      assert is_integer(tempo)
      assert tempo >= 0
    end
  end

  describe "analisar/1" do
    test "retorna estatísticas das leituras" do
      leituras = [
        %Reading{consumer_id: "C1", kwh: 100, timestamp: DateTime.utc_now()},
        %Reading{consumer_id: "C1", kwh: 200, timestamp: DateTime.utc_now()},
        %Reading{consumer_id: "C1", kwh: 300, timestamp: DateTime.utc_now()}
      ]

      stats = Pipeline.analisar(leituras)

      assert stats.total_leituras == 3
      assert stats.validas == 3
      assert stats.consumo_total_kwh == 600.0
      assert stats.consumo_medio_kwh == 200.0
      assert stats.min_kwh == 100.0
      assert stats.max_kwh == 300.0
    end

    test "retorna error para lista sem leituras válidas" do
      leituras = [
        %Reading{consumer_id: "C1", kwh: 0, timestamp: DateTime.utc_now()},
        %Reading{consumer_id: "C1", kwh: -50, timestamp: DateTime.utc_now()}
      ]

      resultado = Pipeline.analisar(leituras)

      assert resultado[:error] != nil
    end
  end
end
