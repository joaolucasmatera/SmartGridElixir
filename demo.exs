# Demo do SmartGridElixir
# Cole este conteúdo no IEx que está rodando

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

# Processar com bandeira verde
fatura_verde = SmartGridElixir.Pipeline.process(leituras, :verde)

# Processar com bandeira amarela
fatura_amarela = SmartGridElixir.Pipeline.process(leituras, :amarela)

# Ver resultado
IO.puts(SmartGridElixir.Invoice.format(fatura_verde))
IO.puts("")
IO.puts(SmartGridElixir.Invoice.format(fatura_amarela))

# Análise estatística
stats = SmartGridElixir.Pipeline.analisar(leituras)
IO.inspect(stats, label: "Estatísticas")
