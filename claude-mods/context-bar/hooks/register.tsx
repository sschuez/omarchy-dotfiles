import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Reading, Segment } from '../types'

// /context-bar: the context window as one stacked bar above the prompt, a
// colour per category as /context draws them, and a legend under it.
// Whether it's shown is kept in $.store, so it stays on across sessions.

const isShown = atom({ plugin: 'context-bar', key: 'isShown' } as const, false)
const reading = atom({ plugin: 'context-bar', key: 'reading' } as const, null, {
  shape: 'reading-1',
})

const SHOWN_KEY = 'isShown'

// A thin gauge: what's in use as a heavy line in its category's colour, the
// compaction buffer dashed, free space a faint line.
const glyph = (kind: string) => (kind === 'free' ? '─' : kind === 'buffer' ? '╍' : '━')
const tint = (s: Segment) => (s.kind === 'free' ? 'subtle' : s.kind === 'buffer' ? 'warning' : s.color)

// The percentage turns from green to yellow to red as the window fills.
const level = (percent: number) => (percent < 60 ? 'success' : percent < 85 ? 'warning' : 'error')

const LEAD = '◆ context  '
const BAR_MAX = 72

const compact = (tokens: number) =>
  tokens >= 1_000_000
    ? `${(tokens / 1_000_000).toFixed(1)}M`
    : tokens >= 1000
      ? `${Math.round(tokens / 1000)}k`
      : `${tokens}`

// Splits `width` cells among the segments by their tokens (largest remainder),
// giving every non-empty segment at least one cell so small ones stay visible.
const cells = (segments: Segment[], width: number): number[] => {
  const total = segments.reduce((sum, s) => sum + s.tokens, 0) || 1
  const exact = segments.map(s => (s.tokens / total) * width)
  const out = exact.map(x => Math.max(1, Math.floor(x)))
  const byRest = exact
    .map((x, i) => ({ i, rest: x - Math.floor(x) }))
    .sort((a, b) => b.rest - a.rest)
  let left = width - out.reduce((a, b) => a + b, 0)
  for (let k = 0; left > 0 && byRest.length > 0; k = (k + 1) % byRest.length, left--) {
    const i = byRest[k]?.i ?? 0
    out[i] = (out[i] ?? 0) + 1
  }
  // Too many one-cell minimums: take the excess back from the widest.
  for (; left < 0; left++) {
    const widest = out.indexOf(Math.max(...out))
    out[widest] = (out[widest] ?? 1) - 1
  }
  return out
}

async function measure($: EngineInterface) {
  const usage = await $.session.usage({ breakdown: 'summary' })
  const breakdown = usage.context.breakdown
  if (!breakdown) return
  const next: Reading = {
    segments: breakdown.categories
      .filter(c => c.kind !== 'deferred' && c.tokens > 0)
      .map(c => ({ name: c.name, color: c.color, tokens: c.tokens, kind: c.kind })),
    used: breakdown.totalTokens,
    max: breakdown.rawMaxTokens,
    percent: breakdown.percentage,
  }
  await update($, reading, () => next)
}

async function toggle($: EngineInterface) {
  const shown = !(await read($, isShown))
  await update($, isShown, () => shown)
  await $.store.set(SHOWN_KEY, shown)
  if (shown) await measure($)
  return shown
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'context-bar',
      description: 'Show or hide the context window as a bar above the prompt',
    })
    await $.command.register({ name: 'cb', description: 'Short for /context-bar' })
    const stored = (await $.store.get(SHOWN_KEY)) === true
    await update($, isShown, () => stored)
    if (stored) await measure($)

    return next(e)
  })

  on('command.run', { command: 'context-bar' }, async $ => {
    const shown = await toggle($)

    return { text: shown ? 'Context bar on.' : 'Context bar off.' }
  })

  on('command.run', { command: 'cb' }, async $ => {
    const shown = await toggle($)

    return { text: shown ? 'Context bar on.' : 'Context bar off.' }
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    if (await read($, isShown)) await measure($)

    return result
  })

  // A failed refresh must never fail the compaction itself.
  on('session.compact', async ($, e, next) => {
    const result = await next(e)
    if (await read($, isShown)) await measure($).catch(() => undefined)

    return result
  }).catch(($, e, next) => next(e))

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const now = await read($, reading)
    if (e.props.hasSurvey || now === null || !(await read($, isShown))) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const tail = `  ${now.percent}%`
    const figures = `  ${compact(now.used)} / ${compact(now.max)}`
    const room = e.props.bodyColumns - LEAD.length - tail.length - figures.length
    const width = Math.max(10, Math.min(BAR_MAX, room))
    const widths = cells(now.segments, width)
    const used = now.segments.filter(s => s.kind === 'used').sort((a, b) => b.tokens - a.tokens)
    const rest = now.segments.filter(s => s.kind !== 'used')
    const pad = ' '.repeat(LEAD.length)

    return (
      <Box flexDirection="column">
        <Box>
          <Text color="claude" bold>
            ◆
          </Text>
          <Text dimColor> context  </Text>
          {now.segments.map((s, i) => (
            <Text color={tint(s)} dimColor={s.kind !== 'used'}>
              {glyph(s.kind).repeat(widths[i] ?? 0)}
            </Text>
          ))}
          <Text color={level(now.percent)} bold>
            {tail}
          </Text>
          <Text dimColor>{figures}</Text>
        </Box>
        <Text wrap="wrap">
          <Text>{pad}</Text>
          {used.map(s => (
            <Text>
              <Text color={s.color}>●</Text>
              <Text dimColor> {s.name} </Text>
              <Text>{compact(s.tokens)}</Text>
              <Text>{'   '}</Text>
            </Text>
          ))}
          {rest.map(s => (
            <Text dimColor>
              <Text color={tint(s)}>{glyph(s.kind)}</Text> {s.kind === 'free' ? 'free' : 'buffer'}{' '}
              {compact(s.tokens)}
              {'   '}
            </Text>
          ))}
        </Text>
      </Box>
    )
  })
}
