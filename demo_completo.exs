#!/usr/bin/env elixir
# Script de demonstração do SmartGridElixir

# Criar algumas leituras de exemplo
leituras = [
  %SmartGridElixir.Reading{
    consumer_id: "C001",
    kwh: 100,
    profile: :residencial,
    timestamp: DateTime.utc_now()
  },
  %SmartGridElixir.Reading{
    consumer_id: "C001",
    kwh: 105,
    profile: :residencial,
    timestamp: DateTime.utc_now()
  },
  %SmartGridElixir.Reading{
    consumer_id: "C001",
    kwh: 102,
    profile: :residencial,
    timestamp: DateTime.utc_now()
  }
]

IO.puts("\n" <> String.duplicate("=", 60))
IO.puts("🎯 DEMONSTRAÇÃO SMARTGRIDELIXIR")
IO.puts(String.duplicate("=", 60) <> "\n")

# Teste 1: Processar com bandeira verde
IO.puts("📊 Teste 1: Processando com BANDEIRA VERDE")
IO.puts("-" <> String.duplicate("-", 58))
fatura_verde = SmartGridElixir.Pipeline.process(leituras, :verde)
IO.puts(SmartGridElixir.Invoice.format(fatura_verde))

# Teste 2: Processar com bandeira amarela
IO.puts("\n📊 Teste 2: Processando com BANDEIRA AMARELA")
IO.puts("-" <> String.duplicate("-", 58))
fatura_amarela = SmartGridElixir.Pipeline.process(leituras, :amarela)
IO.puts(SmartGridElixir.Invoice.format(fatura_amarela))

# Teste 3: Processar com bandeira vermelha
IO.puts("\n📊 Teste 3: Processando com BANDEIRA VERMELHA")
IO.puts("-" <> String.duplicate("-", 58))
fatura_vermelha = SmartGridElixir.Pipeline.process(leituras, :vermelha)
IO.puts(SmartGridElixir.Invoice.format(fatura_vermelha))

# Teste 4: Análise estatística
IO.puts("\n📊 Teste 4: ANÁLISE ESTATÍSTICA")
IO.puts("-" <> String.duplicate("-", 58))
stats = SmartGridElixir.Pipeline.analisar(leituras)
IO.inspect(stats, label: "Estatísticas", pretty: true)

# Teste 5: Com outliers
IO.puts("\n📊 Teste 5: Processando com OUTLIERS")
IO.puts("-" <> String.duplicate("-", 58))
leituras_com_outliers = leituras ++ [
  %SmartGridElixir.Reading{
    consumer_id: "C001",
    kwh: 999,  # Outlier!
    profile: :residencial,
    timestamp: DateTime.utc_now()
  }
]
fatura_outliers = SmartGridElixir.Pipeline.process(leituras_com_outliers, :verde)
IO.puts(SmartGridElixir.Invoice.format(fatura_outliers))

IO.puts("\n" <> String.duplicate("=", 60))
IO.puts("✅ DEMONSTRAÇÃO CONCLUÍDA COM SUCESSO!")
IO.puts(String.duplicate("=", 60) <> "\n")
