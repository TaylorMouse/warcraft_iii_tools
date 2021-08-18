/*
    .SYNOPSIS
    | Behavior (GLBS) for Warcraft III
    
    .COPYRIGHT
    | (c)2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

    .CHANGELOG
    | 0.7 - Encoding and decoding the list of objects from the plugin into the UI
    | 0.6 - Added the UV & Alpha
    | 0.5 - Specify the pos, rot, scale, visibility track of bones and helpers
    | 0.4 - Added the pick material functionality
    | 0.3 - Added the possibility to add bones & helpers
    | 0.2 - Global Sequence can now be defined based on a frame ( and a group )
    | 0.1 - Keeping objects in to a plugin looks like a real pain :/



*/
GLOBAL B_DEBUG = TRUE

rollout Warcraft_III_BehaviorEditor "Behavior Editor" width:250 height:740
(
    local behaviorObj
    local glbs_list = #()
    local current_glbs_object = undefined 
    local selectedItem = undefined
    local selectedObject = undefined
    local selectedGroupId = undefined
    
    struct wcIII_glbs ( groupId, nbrFrames, objectList = #() )
    struct wcIII_glbs_obj 
    ( 
        objRef, 
        objName, 
        flags, 
        type, 
        MATERIAL_UV = false, 
        MATERIAL_ALPHA = false, 
        MATERIAL_EMISSIVE = false,
        
        OBJ_POSITION = false, 
        OBJ_ROTATION = false, 
        OBJ_SCALE = false, 
        VISIBILITY_TRACK = false 
    )
    
    label lblTitle "Behavior Object:" align:#left 
    label lblBehaviorObjName "" align:#left 
    
    group "Global Sequences"
    (
        button btn_CreateGroup "Create new" height:25 width:110 align:#left
        button btn_DeleteGroup "Delete selected" height:25 width:110 offset:[115,-30] align:#left
        
        label lbl_nbrFrame "Nbr Frames:" align:#left
        spinner spn_nbrFrames range:[0,10000,0] offset:[70,-18] width:70 align:#left type:#integer
        
        label lbl_groups "Groups" align:#left
        dotNetControl list_globalSequences "System.Windows.Forms.ListView" width:220 height:150 align:#center
        
        label lbl_selectedGroup "Selected Group: <none>" align:#left
    )

    group "Properties"
    (
        button btn_AddObj "Pick Object" height:25 width:75 align:#left tooltip:"Pick an object to add to the global sequence list, object type must be dummy or bone."
        materialbutton btn_AddMaterial "Pick Material" height:25 width:75 offset:[5,-30]
        button btn_DeleteObj "Remove" height:25 width:60 offset:[160,-30] align:#left
        
        dotNetControl list_selectedObjects "System.Windows.Forms.ListView" width:220 height:150 align:#center
        
        label lbl_selectedObject "Selected object: <none>" align:#left
        
                
        checkbox cbx_material_alpha     "Alpha"    tooltip:"Check if the alpha of the material needs to be part of the global sequence" offset:[0,20]
        checkbox cbx_material_emiss     "Emissive" tooltip:"Check if the emissive of the material needs to be part of the global sequence"
        checkbox cbx_material_uv        "UV"       tooltip:"Check if the uv unwrap of the material needs to be part of the global sequence"
        
        groupbox grpBox_01 "Material" height:100 width:230 offset:[-5,-100]
        
        checkbox cbx_object_position    "Postion"           tooltip:"Check if the position of the object needs to be part of the global sequence" offset:[0,20]
        checkbox cbx_object_rotation    "Rotation"          tooltip:"Check if the rotation of the object needs to be part of the global sequence"
        checkbox cbx_object_scale       "Scale"             tooltip:"Check if the scale of the object needs to be part of the global sequence"
        checkbox cbx_visibility         "Visibility"        tooltip:"Check if the visibility track of the object needs to be part of the global sequence"
        
        groupbox grpBox_02 "Transformations" height:100 width:230 offset:[-5,-100]
    )

    /* 
        FUNCTIONS 
    */
    function MaterialExists mtl=
    (
        if ( mtl == undefined ) then return false
        local exists = false
        
        for obj in objects do 
        (
            
            if ( obj.material != undefined and obj.material.name == mtl.name ) then
            (
                exists = true
                exit
            )
        )
        
        return exists
        
    )
    function DecodeFlags glbsObj=
    (
        
        if ( bit.and glbsObj.flags 0x01 > 0 ) then glbsObj.MATERIAL_UV = true
        if ( bit.and glbsObj.flags 0x02 > 0 ) then glbsObj.MATERIAL_ALPHA = true
        if ( bit.and glbsObj.flags 0x04 > 0 ) then glbsObj.MATERIAL_EMISSIVE = true
        if ( bit.and glbsObj.flags 0x10 > 0 ) then glbsObj.OBJ_POSITION = true
        if ( bit.and glbsObj.flags 0x20 > 0 ) then glbsObj.OBJ_ROTATION = true
        if ( bit.and glbsObj.flags 0x40 > 0 ) then glbsObj.OBJ_SCALE = true
        if ( bit.and glbsObj.flags 0x80 > 0 ) then glbsObj.VISIBILITY_TRACK = true
        
        if B_DEBUG then format "Decoding Flags: %\n" glbsObj
        
        return glbsObj
    )
    function ResetCheckBoxes =
    (
        current_glbs_object = undefined
        cbx_object_position.enabled = false
        cbx_object_rotation.enabled = false
        cbx_object_scale.enabled = false
        cbx_visibility.enabled = false
        cbx_material_uv.enabled = false
        cbx_material_alpha.enabled = false
        cbx_material_emiss.enabled = false
        
        
    )

    function UpdateGlobalSequenceList =
    (
        
        local range = #()
        for obj in glbs_list do
        (
            local item = dotNetObject "System.Windows.Forms.ListViewItem" ( obj.groupId as string )
            item.SubItems.Add ( obj.nbrFrames as string )
            append range item
        )
        list_globalSequences.Items.clear()
        list_globalSequences.Items.AddRange range
        spn_nbrFrames.value = 0
    )

    function DecodeListOfObjects=
    (
        if behaviorObj == undefined then return undefined
        
        if B_DEBUG then format "List of Objects to decode %\n" behaviorObj.ListOfObjects
        
        for str in behaviorObj.ListOfObjects do
        (
            local parts = filterstring str "|"
            
            local glbs = wcIII_glbs groupId:(parts[1] as integer) nbrFrames:(parts[2] as integer )
            
            for i=3 to parts.count by 3 do
            (
                local glbsObj = wcIII_glbs_obj objName:parts[i] type:parts[i+1] flags:(parts[i+2] as integer )
                
                append glbs.objectList ( DecodeFlags glbsObj )
            )
           
            append glbs_list glbs
        )
    
        if B_DEBUG then format "glbs_list:  %\n" glbs_list

    )
    
    function EncodeListOfObjects=
    (
        if behaviorObj == undefined then return undefined

        behaviorObj.ListOfObjects = #()

        for glbs in glbs_list do
        (
            local str = ( glbs.groupId as string ) + "|" + ( glbs.nbrFrames as string ) + "|"

            for obj in glbs.objectList do
            (
                str += obj.objName + "|" + obj.type  + "|" + obj.flags as string + "|"
            )

            append behaviorObj.ListOfObjects str
        )
        
        if B_DEBUG then format "Encoding List of Objects %\n" behaviorObj.ListOfObjects
    )


    function UpdateCheckBoxes =
    (
        local name = selectedObject.subitems.item[0].text
        local type = selectedObject.subitems.item[1].text
        current_glbs_object = undefined
        
        ResetCheckBoxes()
        
        for obj in glbs_list[selectedGroupId].objectList do
        (
            
            if ( obj.objName == name and (obj.type as string) == type ) then 
            (
                current_glbs_object = obj
                if ( obj.type == #MATERIAL ) then
                (
                    cbx_material_uv.enabled = true
                    cbx_material_alpha.enabled = true
                    cbx_material_emiss.enabled = true
                    
                    
                )
                else
                (
                    cbx_object_position.enabled = true
                    cbx_object_rotation.enabled = true
                    cbx_object_scale.enabled = true
                    cbx_visibility.enabled = true
                )
                cbx_material_uv.checked = obj.MATERIAL_UV
                cbx_material_alpha.checked = obj.MATERIAL_ALPHA
                cbx_material_emiss.checked = obj.MATERIAL_EMISSIVE
                
                cbx_object_position.checked = obj.OBJ_POSITION
                cbx_object_rotation.checked = obj.OBJ_ROTATION
                cbx_object_scale.checked = obj.OBJ_SCALE
                cbx_visibility.checked = obj.VISIBILITY_TRACK
                
                
                exit
            
            )
        )
        
        
    )
    function EncodeFlags glbsObj=
    (
        /*
        0x01    MATERIAL_UV
        0x02    MATERIAL_ALPHA
        0x10    OBJ_POSITION
        0x20    OBJ_ROTATION
        0x40    OBJ_SCALE
        0x80    VISIBILITY_TRACK
        0x100   
        */  
        local flags = 0
        if ( glbsObj.MATERIAL_UV )       then flags += 0x01
        if ( glbsObj.MATERIAL_ALPHA )    then flags += 0x02
        if ( glbsObj.MATERIAL_EMISSIVE ) then flags += 0x04
        
        if ( glbsObj.OBJ_POSITION )      then flags += 0x10
        if ( glbsObj.OBJ_ROTATION )      then flags += 0x20
        if ( glbsObj.OBJ_SCALE )         then flags += 0x40
        if ( glbsObj.VISIBILITY_TRACK )  then flags += 0x80

        glbsObj.flags = flags
        
        if B_DEBUG then format "Encoding Flags: %\n" glbsObj
        

    )

    function UpdateObjectList=
    (
        current_glbs_object = undefined
        local range = #()
        
        if B_DEBUG then format "selectedGroupId: %\n" selectedGroupId
        if B_DEBUG then format "Nbr Objects %\n" glbs_list[selectedGroupId].objectList.count
            
        
        for i = 1 to glbs_list[selectedGroupId].objectList.count do
        (
            local obj = glbs_list[selectedGroupId].objectList[i]
            if B_DEBUG then format " - %\n" obj
            
            local item = dotNetObject "System.Windows.Forms.ListViewItem" obj.objName
            item.SubItems.Add ( obj.type as string )
            
            append range item
        )
        list_selectedObjects.Items.clear()
        list_selectedObjects.Items.AddRange range

    )

    function SaveEverything=
    (
        EncodeListOfObjects()   
        
    )
    
    /* 
        BUTTONS 
    */
    on btn_CreateGroup pressed do
    (
        
        if spn_nbrFrames.value == 0 then 
        (
            messagebox "A nbr frames must be greater then ZERO"
            return undefined
        )
        
        local glbs = wcIII_glbs()
        glbs.groupId = list_globalSequences.Items.count + 1
        glbs.nbrFrames = spn_nbrFrames.value
        
        append glbs_list glbs

        UpdateGlobalSequenceList()
        spn_nbrFrames.value = 0
        
    )
    on btn_DeleteGroup pressed do
    (
        if selectedItem == undefined then return undefined
        local index = selectedItem.Text as integer
        
        deleteItem glbs_list index
        
        for i=1 to glbs_list.count do
        (
            glbs_list[i].groupId = i
        )
        
        UpdateGlobalSequenceList()
        selectedItem = undefined
    )
    on btn_AddObj pressed do
    (
        if selectedGroupId == undefined then return undefined
            
        btn_AddObj.enabled = false
        setsyscur #select
        local obj = pickobject()
        
        local objClass = classof obj
        
        if B_DEBUG then 
        (
            local d = wcIII_glbs_obj()
            format "Selected object: %\n" obj
        )
        
        if ( objClass == Dummy or objClass == BoneGeometry ) then
        (
            if objClass == Dummy then objClass = #DUMMY
            if objClass == BoneGeometry then objClass = #BONE
            
            local glbsObj = wcIII_glbs_obj objRef:obj objName:obj.Name flags:0x0 type:objClass
            
            local canAdd = true
            for o in glbs_list[selectedGroupId].objectList do
            (
                if o.objName == obj.Name and o.type ==  objClass then 
                (
                    canAdd = false
                    exit
                )
            )
            if canAdd then append glbs_list[selectedGroupId].objectList glbsObj
        )
        setsyscur #arrow
        btn_AddObj.enabled = true
        
        UpdateObjectList()
    )
    on btn_AddMaterial  picked mtl do
    (
        if ( selectedGroupId == undefined ) then return undefined
        if ( MaterialExists mtl == false  ) then return undefined
        
        local glbsObj = wcIII_glbs_obj objRef:mtl objName:mtl.name flags:0x0 type:#MATERIAL
        local canAdd = true

        for o in glbs_list[selectedGroupId].objectList do
        (
            if o.objName == mtl.name and o.type == #MATERIAL then 
            (
                canAdd = false
                exit
            )
        )
        
        if canAdd then append glbs_list[selectedGroupId].objectList glbsObj
        UpdateObjectList()
    )
    
    /* 
        CHECKBOXES
    */
    on cbx_material_uv changed theState do 
    ( 
        current_glbs_object.MATERIAL_UV = theState 
        EncodeFlags current_glbs_object
    )
    on cbx_material_alpha changed theState do 
    ( 
        current_glbs_object.MATERIAL_ALPHA = theState 
        EncodeFlags current_glbs_object
    )
    on cbx_material_emiss changed theState do 
    ( 
        current_glbs_object.MATERIAL_EMISSIVE = theState 
        EncodeFlags current_glbs_object
    )
    
    on cbx_object_position changed theState do 
    (
        current_glbs_object.OBJ_POSITION = theState 
        EncodeFlags current_glbs_object
    )
    on cbx_object_rotation changed theState do 
    (
        current_glbs_object.OBJ_ROTATION = theState
        EncodeFlags current_glbs_object
    )
    on cbx_object_scale changed theState do 
    ( 
        current_glbs_object.OBJ_SCALE = theState 
        EncodeFlags current_glbs_object
    )
    on cbx_visibility changed theState do 
    ( 
        current_glbs_object.VISIBILITY_TRACK = theState 
        EncodeFlags current_glbs_object
    )
    
    /*
        LISTS
    */
    
    on list_globalSequences ItemSelectionChanged arg do
    (
        selectedItem = arg.Item
        
        if selectedItem != undefined then 
        (
            lbl_selectedGroup.Text = "Selected Group: " + selectedItem.Text
        
            selectedGroupId = selectedItem.Text as integer
            selectedObject = undefined
            
            lbl_selectedObject.Text = "Selected object: <none>"
        )
        UpdateObjectList()
        ResetCheckBoxes()
    )
    
    on list_selectedObjects ItemSelectionChanged arg do
    (
        current_glbs_object = undefined
        selectedObject = arg.Item
        
        if selectedObject != undefined then 
        (

            lbl_selectedObject.Text = "Selected object: " + selectedObject.Text
        )
        UpdateCheckBoxes()
        
    )
    
    /* 
        OPEN  
    */
    on Warcraft_III_BehaviorEditor open do
    (
        for obj in objects do 
        (
            if classof obj == WarcraftIII_Behavior then 
            (
                format "Behavior Object : %\n" obj
                behaviorObj = obj
                lblBehaviorObjName.Text = behaviorObj.Name
                DecodeListOfObjects()
                exit
            )
        )
        
        list_globalSequences.View = (dotNetClass "System.Windows.Forms.View").Details
        list_globalSequences.FullRowSelect = true
        list_globalSequences.gridLines = true
        list_globalSequences.HideSelection = false
        list_globalSequences.Columns.Add "GroupId" 80
        list_globalSequences.Columns.Add "Nbr Frames" -2
        try(list_globalSequences.Items.clear()) catch() 

        list_selectedObjects.View = (dotNetClass "System.Windows.Forms.View").Details
        list_selectedObjects.FullRowSelect = true
        list_selectedObjects.gridLines = true
        list_selectedObjects.HideSelection = false
        list_selectedObjects.Columns.Add "Object Name" 120
        list_selectedObjects.Columns.Add "Type" -2
        try(list_selectedObjects.Items.clear()) catch() 

        
        UpdateGlobalSequenceList()
        ResetCheckBoxes()
    )
    
    /*
        CLOSE
    */
    on Warcraft_III_BehaviorEditor close do
    (
        SaveEverything()
    )
)

/*

    .PLUGIN
    | Warcraft III Behavior UI Plugin

*/
plugin simpleManipulator WarcraftIII_Behavior
    name: "Behavior"
    classID:#(0x23d03ade, 0x7a156813)
    category:"Warcraft III"
(
    local selectedItem
    local selectedObj
    
    parameters main_params rollout:params 
    ( 
        listOfObjects type:#stringTab tabSizeVariable:true
    )
    
    rollout params "Behavior Properties"
    (
        button btnOpenEditor  "Open behavior editor" height:30 width:150 align:#left offset:[-5,0]
        
        on btnOpenEditor pressed do
        (
            
            
            if Warcraft_III_BehaviorEditor.open then 
                DestroyDialog Warcraft_III_BehaviorEditor
            CreateDialog Warcraft_III_BehaviorEditor
        )
    )
    

    tool create
    (
        on mousePoint click do
        (
            
            
            case click of
                 (
                    1:(
                     
                        nodeTM.translation = [0,0,0]
                        listOfItems = #()
                        #stop
                      )
                    2:( #stop )
                  )
        )
    )
    function BuildGizmo points=
    (
        local unselectedColor = [1,0.5,0] 
        local selectedColor = [1,1,0]
        local giz = manip.makeGizmoShape()
        giz.startNewLine()
        for pnt in points do giz.addpoint pnt
        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    function BuildGizmoCircle radius=
    (
        local unselectedColor = [1,0.5,0] 
        local selectedColor = [1,1,0]

        local giz = manip.makeCircle [0,0,0] radius 24

        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    on updateGizmos do
    (
        this.clearGizmos()

        BuildGizmoCircle 50.0
        BuildGizmo #([-20,30,0], [10,30,0],[20,20,0],[20,10,0], [10,0,0],[20,-10,0], [20,-20,0], [10,-30,0],[-20,-30,0],[-20,30,0])
        BuildGizmo #( [-12.5,25,0], [6.5,25,0], [12.5,20,0], [12.5,11,0], [6.5,5,0], [-12.5,5,0],[-12.5,25,0] )
        BuildGizmo #( [-12.5,-25,0], [6.5,-25,0], [12.5,-20,0], [12.5,-11,0], [6.5,-5,0], [-12.5,-5,0],[-12.5,-25,0] )
    )
)