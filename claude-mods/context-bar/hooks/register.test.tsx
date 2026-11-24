import { expect, test } from 'claude-code/testing'

const BAND = {
  plugin: 'context-bar',
  component: 'AbovePrompt',
  props: {
    hasSurvey: false,
    isCollapsed: false,
    isWorking: false,
    maxRows: 10,
    bodyColumns: 60,
    scroll: { offset: 0, bodyRows: 10 },
  },
} as const

const category = (name: string, tokens: number, color: string, kind = 'used') => ({
  name,
  tokens,
  color,
  kind,
  isDeferred: kind === 'deferred',
})

const USAGE = {
  startedAt: 0,
  rateLimits: [],
  context: {
    breakdown: {
      categories: [
        category('System prompt', 4000, 'promptBorder'),
        category('Messages', 46000, 'permission'),
        category('MCP tools (deferred)', 9000, 'inactive', 'deferred'),
        category('Autocompact buffer', 33000, 'warning', 'buffer'),
        category('Free space', 117000, 'inactive', 'free'),
      ],
      totalTokens: 50000,
      maxTokens: 200000,
      rawMaxTokens: 200000,
      percentage: 25,
    },
  },
}

test('/context-bar toggles a stacked bar with a legend', async ($, on) => {
  const stored = new Map<string, unknown>()
  on('command.register', () => ({ value: { command: 'context-bar' } }))
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  on('session.usage', () => ({ value: USAGE as never }))
  on('store.get', (_, e) => ({ value: stored.get(e.key) }))
  on('store.set', (_, e) => {
    stored.set(e.key, e.value)
    return { value: undefined }
  })

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  let ui = await $.ui.mount({ ...BAND, surface: 'terminal' } as never)
  expect(await ui.find({ type: 'Text', text: /Messages/ })).toBe(undefined)
  await ui.unmount()

  expect((await $.command.run({ command: 'context-bar' } as never)).text).toBe('Context bar on.')

  ui = await $.ui.mount({ ...BAND, surface: 'terminal' } as never)
  expect((await ui.find({ type: 'Text', text: /25%/ }))?.text).toBe('  25%')
  expect(await ui.find({ type: 'Text', text: /Messages 46k/ })).toBeTruthy()
  // Deferred tool schemas sit outside the window, so they're left out.
  expect(await ui.find({ type: 'Text', text: /deferred/ })).toBe(undefined)
  await ui.unmount()

  expect((await $.command.run({ command: 'cb' } as never)).text).toBe('Context bar off.')
  ui = await $.ui.mount({ ...BAND, surface: 'terminal' } as never)
  expect(await ui.find({ type: 'Text', text: /Messages/ })).toBe(undefined)
  await ui.unmount()
})
