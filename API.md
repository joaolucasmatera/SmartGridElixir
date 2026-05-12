# API REST - SmartGrid

## Visão Geral

A API REST do SmartGrid expõe o sistema de faturamento de energia elétrica como um microsserviço HTTP.

## Endpoints

### POST /api/invoices

Processa leituras de medidor e retorna uma fatura calculada.

#### Request

**Content-Type**: `application/json`

```json
{
  "consumerId": "C001",
  "bandeira": "verde",
  "readings": [
    {
      "consumerId": "C001",
      "kwh": 100.0,
      "timestamp": "2024-01-01T00:00:00Z",
      "profile": "residencial",
      "valid": true
    },
    {
      "consumerId": "C001",
      "kwh": 110.0,
      "timestamp": "2024-01-02T00:00:00Z",
      "profile": "residencial",
      "valid": true
    }
  ]
}
```

**Campos obrigatórios**:
- `consumerId`: Identificador único do consumidor (string)
- `bandeira`: Bandeira tarifária - `verde`, `amarela` ou `vermelha` (string)
- `readings`: Array de leituras (array)

**Campos de cada leitura**:
- `consumerId`: ID do consumidor (string)
- `kwh`: Consumo em quilowatt-hora (número)
- `timestamp`: Data/hora da leitura (ISO 8601)
- `profile`: Tipo de consumidor - `residencial`, `comercial` ou `industrial` (string)
- `valid`: Se a leitura é válida (boolean)

#### Response (Success - 200)

```json
{
  "consumerId": "C001",
  "totalAmount": 75.60,
  "consumptionKwh": 210.0,
  "profile": "residencial",
  "bandeira": "verde",
  "outliers": 0,
  "generatedAt": "2024-05-11T14:30:00.123456Z"
}
```

**Campos de resposta**:
- `consumerId`: ID do consumidor
- `totalAmount`: Valor total da fatura em reais (número, 2 casas decimais)
- `consumptionKwh`: Consumo total em kWh após remoção de outliers
- `profile`: Tipo de consumidor
- `bandeira`: Bandeira aplicada
- `outliers`: Quantidade de leituras removidas como outliers
- `generatedAt`: Data/hora de geração da fatura (ISO 8601)

#### Response (Error - 400)

```json
{
  "error": "Invalid request format"
}
```

**Possíveis erros**:
- `"Invalid request format"`: JSON inválido ou campos obrigatórios faltando
- `"Malformed JSON"`: Erro ao decodificar JSON
- `"Failed to process readings"`: Erro interno no pipeline de processamento

### GET /health

Verifica o status da API.

#### Response (Success - 200)

```json
{
  "status": "ok"
}
```

## Regras de Negócio

### Validação de Leituras
- Leituras com valor de Z-score > 3 são consideradas outliers e removidas
- Apenas leituras válidas são processadas

### Cálculo de Tarifas

#### Base tarifária por perfil:
- **Residencial**: R$ 0,72/kWh
- **Comercial**: R$ 0,85/kWh
- **Industrial**: R$ 0,62/kWh

#### Multiplicadores de bandeira:
- 🟢 **Verde**: 1,00x (sem adicional)
- 🟡 **Amarela**: 1,021x (+2,1%)
- 🔴 **Vermelha**: 1,040x (+4,0%)

#### Desconto por volume:
- Consumo > 500 kWh: -5% no total

## Fluxo de Processamento

1. **Validação**: Verifica formato JSON e presença de campos obrigatórios
2. **Remoção de Outliers**: Aplica Z-score para remover leituras anômalas
3. **Cálculo de Tarifa**: Multiplica kWh × tarifa base × bandeira × desconto
4. **Agregação**: Soma todos os valores processados
5. **Geração de Fatura**: Cria Invoice com metadados
6. **Serialização**: Converte para JSON conforme contrato

## Exemplos de Uso

### curl
```bash
curl -X POST http://localhost:4000/api/invoices \
  -H "Content-Type: application/json" \
  -d '{
    "consumerId": "C001",
    "bandeira": "verde",
    "readings": [
      {"consumerId": "C001", "kwh": 100.0, "timestamp": "2024-01-01", "profile": "residencial", "valid": true}
    ]
  }'
```

### Elixir (com HTTPClient)
```elixir
payload = %{
  "consumerId" => "C001",
  "bandeira" => "verde",
  "readings" => [%{"consumerId" => "C001", "kwh" => 100.0, "timestamp" => "2024-01-01", "profile" => "residencial", "valid" => true}]
}

HTTPoison.post!("http://localhost:4000/api/invoices", Jason.encode!(payload), [{"Content-Type", "application/json"}])
```

## Códigos HTTP

| Código | Significado |
|--------|-------------|
| 200    | Sucesso - Fatura gerada |
| 400    | Erro - Request inválido |
| 404    | Erro - Endpoint não encontrado |

## Performance

- **Tempo típico de processamento**: < 10ms para ~100 leituras
- **Escalabilidade**: Suportado processamento em lote via Pipeline.process_lote/2

## Autenticação

Não implementada nesta versão. Adicionar Bearer token ou API key conforme necessário.

## Rate Limiting

Não implementado nesta versão.
