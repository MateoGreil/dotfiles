import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

interface ActiveMessage {
  startedAt: number;
  firstTokenAt: number | null;
}

interface Measurement {
  ttftMs: number | null;
  responseMs: number;
  speed: number;
}

function formatSpeed(speed: number): string {
  if (speed < 1000) {
    return `${speed.toFixed(0)}tok/s`;
  }
  return `${(speed / 1000).toFixed(1)}kt/s`;
}

function formatDuration(durationMs: number): string {
  if (durationMs < 1000) {
    return `${durationMs.toFixed(0)}ms`;
  }
  return `${(durationMs / 1000).toFixed(1).replace(/\.0$/, "")}s`;
}

export default function (pi: ExtensionAPI) {
  let turnStartedAt: number | null = null;
  let activeMessage: ActiveMessage | null = null;
  let lastSuccessfulMeasurement: Measurement | null = null;

  pi.on("agent_start", () => {
    if (turnStartedAt === null) {
      turnStartedAt = performance.now();
      lastSuccessfulMeasurement = null;
    }
    activeMessage = null;
  });

  pi.on("message_start", (event) => {
    if (event.message.role !== "assistant") return;
    activeMessage = {
      startedAt: performance.now(),
      firstTokenAt: null,
    };
  });

  pi.on("message_update", (event) => {
    if (!activeMessage || event.message.role !== "assistant") return;

    const assistantMessageEvent = event.assistantMessageEvent;
    if (
      assistantMessageEvent.type !== "text_delta" &&
      assistantMessageEvent.type !== "thinking_delta" &&
      assistantMessageEvent.type !== "toolcall_delta"
    ) {
      return;
    }
    if (assistantMessageEvent.delta.length === 0) return;

    activeMessage.firstTokenAt ??= performance.now();
  });

  pi.on("message_end", (event) => {
    if (!activeMessage || event.message.role !== "assistant") return;
    const message = activeMessage;
    activeMessage = null;

    if (
      event.message.stopReason !== "stop" &&
      event.message.stopReason !== "length" &&
      event.message.stopReason !== "toolUse"
    ) {
      return;
    }

    const endedAt = performance.now();
    const responseMs = endedAt - message.startedAt;
    const ttftMs = message.firstTokenAt === null ? null : message.firstTokenAt - message.startedAt;
    const throughputMs = message.firstTokenAt === null ? responseMs : endedAt - message.firstTokenAt;
    const outputTokens = event.message.usage.output;
    const speed = throughputMs > 0 ? outputTokens / (throughputMs / 1000) : 0;

    lastSuccessfulMeasurement = {
      ttftMs,
      responseMs,
      speed,
    };
  });

  pi.on("agent_settled", (_event, ctx) => {
    if (turnStartedAt === null) return;

    const turnMs = performance.now() - turnStartedAt;
    turnStartedAt = null;
    if (lastSuccessfulMeasurement === null || !ctx.hasUI) return;

    const measurement = lastSuccessfulMeasurement;
    const ttft = measurement.ttftMs === null ? "--" : formatDuration(measurement.ttftMs);
    const display = `⚡${formatSpeed(measurement.speed)} · TTFT ${ttft} · réponse ${formatDuration(measurement.responseMs)} · tour ${formatDuration(turnMs)}`;

    ctx.ui.setStatus("perf-metrics", display);
  });
}
