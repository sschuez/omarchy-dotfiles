export type Segment = { name: string; color: string; tokens: number; kind: string }
export type Reading = { segments: Segment[]; used: number; max: number; percent: number }

declare module 'claude-code' {
  interface PluginState {
    'context-bar': { isShown: boolean; reading: Shaped<Reading | null> }
  }
}
