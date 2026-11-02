/// Every upgradable part of a bike. The enum order is persisted by index in
/// saves — only APPEND new values, never reorder.
library;

enum UpgradeType {
  gearRatio, // top speed
  chain, // acceleration
  steering, // lane switch speed
  suspension, // jump height
  frame, // extra hit points
  tires, // stumble slowdown reduction
  magnet, // magnet duration
  shield, // shield duration
  turbo, // turbo duration
  coinPouch, // coin value
  luck, // power-up & gem spawn chance
  headlight, // night visibility
}
