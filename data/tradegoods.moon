export *

trade_goods =
  wood: {weight: 2, per_worker: 0.2}
  rifles: {needs: {metal: 5, wood: 1}, weight: 5, per_worker: 0.2}
  food: {weight: 2, per_worker: 3}