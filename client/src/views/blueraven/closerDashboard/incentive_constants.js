import {MilestoneEnum} from "@/views/blueraven/closerDashboard/MilestoneEnum";

/**Values that can be changed for new theme*/
const firstMilestone = "Bronze"
const secondMilestone = "Silver"
const thirdMilestone = "Gold"
const fourthMilestone = "Platinum"

//Closers
const closerFirstMilestoneGoal = 10
const closerSecondMilestoneGoal = 12
const closerThirdMilestoneGoal = 15
const closerFourthMilestoneGoal = 18

//Setters
const setterFirstMilestoneGoal = 60
const setterSecondMilestoneGoal = 80
const setterThirdMilestoneGoal = 100
const setterFourthMilestoneGoal = 120

//Setter Managers
const setterMgrFirstMilestoneGoal = 325
const setterMgrSecondMilestoneGoal = 455
const setterMgrThirdMilestoneGoal = 585
const setterMgrFourthMilestoneGoal = 780

/** */

let incentive_constants = {}
let milestoneMap = new Map();
milestoneMap.set(MilestoneEnum.LEVEL1, firstMilestone)
milestoneMap.set(MilestoneEnum.LEVEL2, secondMilestone)
milestoneMap.set(MilestoneEnum.LEVEL3, thirdMilestone)
milestoneMap.set(MilestoneEnum.LEVEL4, fourthMilestone)

incentive_constants.totalPointsPossible = 8
incentive_constants.milestoneMap = milestoneMap


const DashboardTypeEnum = Object.freeze({
    CLOSER: {
        milestoneGoalMap:{
            [MilestoneEnum.LEVEL1]:closerFirstMilestoneGoal,
            [MilestoneEnum.LEVEL2]:closerSecondMilestoneGoal,
            [MilestoneEnum.LEVEL3]:closerThirdMilestoneGoal,
            [MilestoneEnum.LEVEL4]:closerFourthMilestoneGoal
        },
        milestoneUnits: 'FDC',
        drilldown: {
            label: ' | Final Designs Completed - Q',
            path: '/closerDashboard/finalDesignsCompletedDrilldown'
        }
    },
    SETTER: {
        milestoneGoalMap:{
            [MilestoneEnum.LEVEL1]:setterFirstMilestoneGoal,
            [MilestoneEnum.LEVEL2]:setterSecondMilestoneGoal,
            [MilestoneEnum.LEVEL3]:setterThirdMilestoneGoal,
            [MilestoneEnum.LEVEL4]:setterFourthMilestoneGoal
        },
        milestoneUnits: 'Pitches',
        drilldown: {
            label: ' | Pitches - Q',
            path: '/setterDashboard/pitchesDrilldown'
        }
    },
    SETTERMGR: {
        milestoneGoalMap: {
            [MilestoneEnum.LEVEL1]: setterMgrFirstMilestoneGoal,
            [MilestoneEnum.LEVEL2]: setterMgrSecondMilestoneGoal,
            [MilestoneEnum.LEVEL3]: setterMgrThirdMilestoneGoal,
            [MilestoneEnum.LEVEL4]: setterMgrFourthMilestoneGoal
        },
        milestoneUnits: 'Pitches',
        drilldown: {
            label: ' | Pitches - Q',
            path: '/setterDashboard/pitchesDrilldown'
        }
    }
})

export {incentive_constants, DashboardTypeEnum}

export function getValuesByMilestoneAndDashboardType(){

}

