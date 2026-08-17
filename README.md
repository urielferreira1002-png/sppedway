# SpeedWay

Velocímetro GPS, rastreador de viagens e navegação — app web mobile-first (PWA-ready), construído com TanStack Start + React + TypeScript + Tailwind.

## Rodar

```bash
bun install
bun run dev     # http://localhost:8080
bun run build   # build de produção
```

## Telas

- `/` — velocímetro principal, métricas da viagem e iniciar/finalizar viagem
- `/velocimetro` — modo tela cheia (adapta-se automaticamente ao modo horizontal)
- `/mapa` — mapa em tempo real, busca de destino, rotas alternativas e navegação
- `/estatisticas` — hoje, semana (gráfico de barras) e mês
- `/viagens` e `/viagens/:id` — histórico e detalhe com a rota no mapa
- `/configuracoes` — unidade (km/h ou mph), limite de velocidade, tema

## Como funciona o GPS

- `navigator.geolocation.watchPosition` com alta precisão e watch contínuo.
- Velocidade vem do GPS (`coords.speed`) e, quando ausente, é derivada da distância/tempo entre fixes.
- Filtros aplicados: descarte de fixes com precisão pior que 100 m, limite de plausibilidade (324 km/h), limiar de movimento proporcional à precisão (4–25 m) e filtro passa-baixa para suavizar oscilações. Abaixo de ~4 km/h o app considera veículo parado (mostra 0, não acumula distância).
- Distância por Haversine, somando apenas deslocamentos acima do limiar.

## Mapas e rotas

- Tiles: OpenStreetMap via Leaflet (sem chave de API).
- Busca de endereços: Nominatim. Cálculo de rotas e instruções: OSRM (rotas alternativas, distância, ETA).
- Para produção em escala, troque por Mapbox ou Google Maps: as chamadas estão isoladas em `src/lib/navigation.ts` e o mapa em `src/components/MapCanvas.tsx`. Nunca coloque chaves no código — use variáveis de ambiente (`VITE_*` para chaves públicas de mapa, `process.env` em server functions para chaves secretas).

## Offline

Viagens e configurações são salvas em `localStorage` (`src/lib/storage.ts`). O velocímetro, a distância e o registro de viagens funcionam sem internet; apenas mapa, busca e rotas precisam de rede.

## Testar

- **GPS:** no Chrome DevTools, aba Sensors > Location, escolha uma localização ou um percurso. Em campo, abra o app pelo celular via HTTPS (a geolocalização exige contexto seguro) e conceda a permissão de localização.
- **Offline:** DevTools > Network > Offline; inicie e finalize uma viagem e confira que ela é salva em `/viagens`.

## Permissões

O app solicita apenas localização enquanto em uso, no primeiro acesso, e explica o estado do sinal (ativo / buscando / indisponível) na tela principal.

## Nota sobre React Native / Expo

Este projeto entrega o SpeedWay como aplicativo web mobile (instalável na tela inicial). A plataforma não compila projetos React Native/Expo. Toda a lógica de GPS, viagens e estatísticas está isolada em `src/lib` e `src/hooks`, o que facilita um port futuro para Expo.
