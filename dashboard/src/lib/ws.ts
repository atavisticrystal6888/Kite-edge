import { Socket, Channel } from 'phoenix'

let socket: Socket | null = null
const channels = new Map<string, Channel>()

export function getSocket(): Socket {
  if (socket) return socket
  const url = (import.meta.env.VITE_GATEWAY_URL ?? 'http://localhost:4000').replace(/^http/, 'ws')
  socket = new Socket(`${url}/socket`, { params: {} })
  socket.connect()
  return socket
}

export function joinChannel(topic: string, params: Record<string, unknown> = {}): Channel {
  const existing = channels.get(topic)
  if (existing) return existing

  const s = getSocket()
  const ch = s.channel(topic, params)
  ch.join()
  channels.set(topic, ch)
  return ch
}

export function leaveChannel(topic: string): void {
  const ch = channels.get(topic)
  if (ch) {
    ch.leave()
    channels.delete(topic)
  }
}
