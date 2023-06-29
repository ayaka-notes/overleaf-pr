import {
  DocId,
  ReviewPanelEntries,
  ReviewPanelPermissions,
  SubView,
} from '../../../../../../../types/review-panel/review-panel'

export interface ReviewPanelState {
  values: {
    collapsed: Record<string, boolean>
    entries: ReviewPanelEntries
    permissions: ReviewPanelPermissions
    shouldCollapse: boolean
    subView: SubView
    wantTrackChanges: boolean
    openDocId: DocId | null
    toggleTrackChangesForEveryone: (isOn: boolean) => unknown
    toggleTrackChangesForUser: (isOn: boolean, memberId: string) => unknown
    toggleTrackChangesForGuests: (isOn: boolean) => unknown
    trackChangesState: Record<string, { value: boolean; syncState: string }>
    trackChangesOnForEveryone: boolean
    trackChangesOnForGuests: boolean
    trackChangesForGuestsAvailable: boolean
    formattedProjectMembers: Record<
      string,
      {
        id: string
        name: string
      }
    >
    toggleReviewPanel: () => void
  }
  updaterFns: {
    handleSetSubview: (subView: SubView) => void
    setCollapsed: React.Dispatch<
      React.SetStateAction<ReviewPanelState['values']['collapsed']>
    >
    setShouldCollapse: React.Dispatch<
      React.SetStateAction<ReviewPanelState['values']['shouldCollapse']>
    >
  }
}

// Getter for values
export type Value<T extends keyof ReviewPanelState['values']> =
  ReviewPanelState['values'][T]