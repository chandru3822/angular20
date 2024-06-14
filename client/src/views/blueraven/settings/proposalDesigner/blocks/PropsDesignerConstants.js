export const PAGE_BLOCK = {
    id:'PageBlock',
    typeId:1,
    label: 'New Page',
    value: {}
}

export const TEXT_BLOCK = {
    id: 'TextBlock',
    typeId: 3,
    label: 'Text Block',
    value: {
        type: 'doc',
        content: [
            {
                type: 'paragraph',
                content: [
                    {
                        type: 'text',
                        text: 'Add text here'
                    }
                ]
            }
        ]
    }
}
export const IMAGE_BLOCK = {
    id: 'ImageBlock',
    label: 'Image Block',
    typeId: 4,
    value: { url: 'https://picsum.photos/200' }
}
export const CONTAINER_BLOCK = {
    id: 'ContainerBlock',
    label: 'Container Block',
    typeId: 2,
    value: {}
}
export const PLACEHOLDER_BLOCK = {
    id: 'PlaceholderBlock',
    label: 'Placeholder Block',
    typeId: 5,
    value: {}
}

export const BLOCK_TYPES = [PAGE_BLOCK,TEXT_BLOCK, IMAGE_BLOCK, CONTAINER_BLOCK, PLACEHOLDER_BLOCK]
