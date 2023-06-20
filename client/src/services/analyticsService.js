import { postRequest } from '@/helpers/helpers'
import {event} from 'vue-gtag'

export var readNoteStartTime = null;
export var writeNoteStartTime = null;
export var currentProjectId = null;
export var readNoteTimerStartEvent = null;
export var writeNoteTimerStartEvent = null;

export async function projectOpened(newProjectId){
  readNoteStartTime = null;
  writeNoteStartTime = null;
  currentProjectId = newProjectId;
}

export async function startTimer (timerStartEvent) {
  if(readNoteStartTime == null) {
    readNoteStartTime = new Date();
    readNoteTimerStartEvent = timerStartEvent;
  }
}

export async function endTimer (endEvent) {
  if(readNoteStartTime != null) {
    let url = `/note/saveProjectNoteTimer`
    let body = {
      projectId: currentProjectId,
      startTimestamp: readNoteStartTime,
      endTimestamp: new Date(),
      timerType: 'Read Note',
      startEvent: readNoteTimerStartEvent,
      endEvent: endEvent
    }
    await postRequest(url, body)
    readNoteStartTime = null;
    readNoteTimerStartEvent = null;
  }
}

export async function writeNoteStartTimer (timerStartEvent) {
  if(writeNoteStartTime == null) {
    writeNoteStartTime = new Date();
    writeNoteTimerStartEvent = timerStartEvent;

  }
}

export async function writeNoteEndTimer (endEvent) {
  if(writeNoteStartTime != null) {
    let url = `/note/saveProjectNoteTimer`
    let body = {
      projectId: currentProjectId,
      startTimestamp: writeNoteStartTime,
      endTimestamp: new Date(),
      timerType: 'Write Note',
      startEvent: writeNoteTimerStartEvent,
      endEvent: endEvent
    }
    await postRequest(url, body)
    writeNoteStartTime = null;
  }
}
