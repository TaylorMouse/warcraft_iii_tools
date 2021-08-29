/*
    .SYNOPSIS
    | Helper functions for Warcraft III mdx (old version = version 800 )
    
    .COPYRIGHT
    | (c)2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/

STRUCT Warcraft_III_Helpers
(
    function ReadVector3Anim stream=
    (
        /*
        .INFO
        | LineType:
        |   NO_INTERP = 0x0
        |   LINEAR    = 0x1
        |   HERMITE   = 0x2
        |   BEZIER    = 0x3

        */
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = [readFloat stream, readFloat stream, readFloat stream]
            k.LineType = anim.lineType

            if( anim.lineType > 1)  then
            (
                k.inTan = [readFloat stream, readFloat stream, readFloat stream]
                k.outTan = [readFloat stream, readFloat stream, readFloat stream]
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadQuatAnim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                --format "Linetype: %\n" lineType
                k.inTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
                k.outTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadFloatAnim stream=
    (
        
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = readFloat stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadVector3 stream=
    (
        local vector3 = [readFloat stream, readFloat stream, readFloat stream]
        return vector3
    ),
    function ReadColor stream=
    (
        local r = (readFloat stream * 255.0) as integer
        local g = (readFloat stream * 255.0) as integer
        local b = (readFloat stream * 255.0) as integer
        return ( color r g b )
    ),
    function ReadTris stream=
    (
        local tris = [readshort stream + 1, readshort stream + 1, readshort stream + 1]
        return tris
    ),
    function ReadColorAnim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = Warcraft3_Reforged.ReadColor stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadLongAnim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = GriffonStudios_Helpers.RoundToFrame ( ReadLong stream )
            k.Point = readLong stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
        
    ),
    function WriteFixedString stream str len=
    (
        if ( WC3_DEBUG ) then  Format " - Writing %\n" str
        for i=1 to str.count do
        (
            local byte = bit.charasint str[i]
            writeByte stream byte
        )
        for i=1 to (len - str.count) do
            writeByte stream 0
    ),
    function WriteTris stream tris=
    (
        writeShort stream tris[1]
        writeShort stream tris[2]
        writeShort stream tris[3]
    ),
    function WriteVector3 stream vector3=
    (
         writeFloat stream vector3.X
         writeFloat stream vector3.Y
         writeFloat stream vector3.Z
        
        
    ),
    function WriteQuat stream quaternian=
    (
        writeFloat stream quaternian.x
        writeFloat stream quaternian.y
        writeFloat stream quaternian.z
        writeFloat stream quaternian.w

    ),
    function WriteVector4 stream vector4=
    (
        writeFloat stream vector4[1]
        writeFloat stream vector4[2]
        writeFloat stream vector4[3]
        writeFloat stream vector4[4]
        
    ),
    /* Get the biggest bounding box from all models between 2 frame, as animation changes these bounding boxes */
    function GetMODLBoundingBoxBetweenFrames startFrame endFrame=
    (
        if ( WC3_DEBUG ) then Format "Calculating MODL Boundingbox between frame % and %\n" startFrame endFrame
        local allKeys = GriffonStudios_Helpers.GetAllAnimatedKeyFrames()

        maxPoint = [0,0,0]
        minPoint = [0,0,0]

        for t in allKeys do
        (
            if ( t >= startFrame and t <= endFrame ) then 
            (
                at time t 
                for obj in objects do
                (
                    if ( classof obj == Editable_Mesh and obj.visibility == true ) then
                    (
                        local bbMax = obj.max
                        
                        for i=1 to 3 do
                            if( maxPoint[i] < bbMax[i] ) then maxPoint[i] = bbMax[i]
                        
                        local bbMin = obj.min
                        
                        for i=1 to 3 do
                            if( minPoint[i] > bbMin[i] ) then minPoint[i] = bbMin[i]
                        
                    )
                )
            )
        )
        local bbox = #()
        append bbox minPoint
        append bbox maxPoint

        return bbox
    ),
    /* Get the biggest bounding box for the whole set of animations keys, specifically needed for the MODL chunk */
    function GetMODLBoundingBox =
    (
        local lastFrame = GriffonStudios_Helpers.FindLastKeyFrame()
        if ( lastFrame <= 1 ) then lastFrame = 10
        bbox = Warcraft_III_Helpers.GetMODLBoundingBoxBetweenFrames 1 lastFrame
        
        return bbox
        
    ),
    /* get the list of animation sequences from the animation track */
    function GetSEQS mdx=
    (
        struct WC3AnimSequence ( Name, StartFrame, EndFrame, MovementSpeed=0.0, NoLoop=0, Rarity=0, Priority=0, Default=0, BBox )
        
        local size = 132

        local seqs = #()
        
        local wc3startFrame = 0
        local wc3EndFrame = 0
        
        if( numNoteTracks rootNode > 0 ) then 
        (
            local track = getNoteTrack rootNode 1
            local keys = track.Keys
            
            for i=1 to keys.count by 2 do
            (
                local note = keys[i].value
                local parts = filterstring note "\r\n"
                local s = WC3AnimSequence()
                
                s.name = parts[1]
                if ( WC3_DEBUG ) then  format " %\n" s.name
                local StartFrame = (getnotekeytime track i)  as integer / TicksPerFrame
                local EndFrame = (getnotekeytime track (i+1)) as integer / TicksPerFrame
            
                s.BBox = Warcraft_III_Helpers.GetMODLBoundingBoxBetweenFrames startFrame endFrame
                s.StartFrame =  startFrame * 1000 / 30 --wc3startFrame
                s.EndFrame =  EndFrame * 1000 / 30 -- wc3EndFrame
                
                --wc3startFrame = wc3EndFrame + 34
                s.Default = 0
                    
                for i=2 to parts.count do
                (
                    local split = filterString parts[i] " = "
                    local key = split[1]
                    local value = split[2]
                    
                    --if ( WC3_DEBUG ) then format " -  %: '%' \n" key value
                    
                    if ( key == "rarity" ) then s.rarity = (value  as float ) / 100.0
                    if ( key == "moveSpeed" ) then s.movementSpeed = value as float
                    if ( key == "nonLoop" ) then 
                    (
                        s.noLoop = value as float
                        if ( value == "true" ) then s.noLoop = 1
                        if ( value == "false" ) then s.noLoop = 0
                        
                    )       
                    if ( key == "defaultPriority" ) then s.Priority = value as float

                )
                
                append seqs s
            )
        )
        else
        (
            local startFrame = 1000 / 30
            local endFrame = 50 * 1000 / 30
            local seq = WC3AnimSequence Name:"Stand 1" StartFrame:startFrame EndFrame:endFrame
            
            seq.BBox = Warcraft_III_Helpers.GetMODLBoundingBoxBetweenFrames 10 60
            
            append seqs seq
        )
        
        mdx.seqs = seqs
    ),
    function GetBehaviorObject = 
    (
        local behaviorObj = Warcraft_III_Helpers.GetBehavior()
        if behaviorObj == undefined then return undefined
        
        local glbs_list = #()
        struct wcIII_glbs ( groupId, nbrFrames, objectList = #() )
        struct wcIII_glbs_obj 
        ( 
            objRef, objName, flags, type, 
            MATERIAL_UV = false, 
            MATERIAL_ALPHA = false, 
            MATERIAL_EMISSIVE = false,
            
            OBJ_POSITION = false, 
            OBJ_ROTATION = false, 
            OBJ_SCALE = false, 
            VISIBILITY_TRACK = false 
        )
        
        for str in behaviorObj.ListOfObjects do
        (
            local parts = filterstring str "|"
            local glbs = wcIII_glbs groupId:(parts[1] as integer) nbrFrames:(parts[2] as integer )

            for i=3 to parts.count by 3 do
            (
                local glbsObj = wcIII_glbs_obj objName:parts[i] type:parts[i+1] flags:(parts[i+2] as integer )
                append glbs.objectList ( Warcraft_III_Helpers.DecodeFlags glbsObj )
            )
            append glbs_list glbs
            if WC3_MDX800_DEBUG then print glbs
        )
        return glbs_list 
        
    ),
    function GetGLBS mdx=
    (
        mdx.glbs = Warcraft_III_Helpers.GetBehaviorObject()

        format "% \n" mdx.glbs
        return mdx.glbs
    ),
    /* get the unique list of TEXS */
    function GetTEXS mdx=
    (
        struct texs800 ( replacableId, path= "", flags = 3, check, original_path = "" )
        local texs = #()
        
        for obj in objects do
        (
            if ( obj.material != undefined ) then
            (
                if ( classof obj.material == compositematerial) then 
                (
                    for subMat in obj.material.materialList do
                    (
                        if ( classof subMat == WarcraftIII_Standard ) then
                        (
                            local tex = texs800()
                            tex.replacableId = subMat.ReplaceableTexture - 1
                            if( tex.replacableId == 0 ) then 
                            (
                                tex.path = ( getfilenamefile subMat.Diffuse_map.filename ) + WC3_TEXTURE_EXPORT_EXTENSION
                                tex.original_path = subMat.Diffuse_map.filename
                            )
                            if ( tex.replacableId == 2 ) then tex.flags = 0
                            tex.check = tex.replacableId as string + tex.path + tex.flags as string
                            append texs tex
                        )
                    )
                )
                if ( classof obj.material == WarcraftIII_Standard ) then
                (
                    local tex = texs800()
                    tex.replacableId = obj.material.ReplaceableTexture - 1
                    if( tex.replacableId == 0 ) then 
                    (
                        tex.path = ( getfilenamefile obj.material.Diffuse_map.filename ) + WC3_TEXTURE_EXPORT_EXTENSION
                        tex.original_path = obj.material.Diffuse_map.filename
                    )
                    if ( tex.replacableId == 2 ) then tex.flags = 0
                    tex.check = tex.replacableId as string + tex.path + tex.flags as string
                    append texs tex
                )
                
            )
        )
        uniqueTexs = #()
        for t in texs do
        (
            if uniqueTexs.count == 0 then 
            (
                append uniqueTexs t
            )
            else
            (
                local addit = true
                for u in uniqueTexs do
                (
                    if u.check == t.check then
                    (
                       addit = false
                        exit
                    )
                )
                if ( addit ) then append uniqueTexs t
            )
        )
        mdx.texs = uniqueTexs
        
        if WC3_MDX800_DEBUG then  for t in uniqueTexs do print t
        
    ),
    /* get a unique list of materials */
    function GetMTLS mdx= 
    (
        struct mtls800 ( materialRef, txanId ) 
        local uniqueMatList = #()
        for obj in objects do
        (
            if ( obj.material != undefined ) then 
            (
                if ( classof obj.material == compositeMaterial ) then
                (
                    if( classof obj.material.materialList[1] == WarcraftIII_Standard ) then appendIfUnique uniqueMatList obj.material
                )
                if ( classof obj.material == WarcraftIII_Standard ) then appendIfUnique uniqueMatList obj.material
            )
        )
        
        local matList = #()
        for um in uniqueMatList do
            append matList ( mtls800 materialRef:um txanId:-1 )
        
        if WC3_MDX800_DEBUG then for m in matList do print m
        mdx.mtls = matList
    ),
    /* get the weights from the vertices per mesh */
    function GetWeights theMesh mdx=
    (
        struct weights800 ( matrices = #(), mtgc = #(), gndx = #() )
        struct vertex_weight ( vertex, boneIndices = #(), crc = "")
        
        local weights = weights800()
        
        select theMesh
        max modify mode
        local skinMod = modPanel.getCurrentObject()

        local vertex_weight_list = #()
        for v=1 to skinOps.getnumbervertices skinMod do
        (
            local vw = vertex_weight vertex:v
            local vertexweightcount = skinops.getvertexweightcount skinMod v

            for w=1 to vertexweightcount do
            (
                local boneId = skinOps.getvertexweightboneid skinMod v w
                local boneName = skinOps.getBonename skinMod boneId 0
                
                for obj in mdx.allobjects do
                (
                    if ( obj.objRef.name == boneName ) then 
                    (
                        append vw.boneIndices obj.id
                        vw.crc += obj.id as string + "|"
                        exit
                    )
                )
            )
            
            append vertex_weight_list vw
            
        )
        -- > annoyingly necessary to apply the correct weights to the correct vertices
        local tvVertices = #()
        for i=1 to theMesh.numFaces do
        (
            local f = getFace theMesh i
            local u = getTvFace theMesh i
            tvVertices[u.x] = f.x as integer
            tvVertices[u.y] = f.y as integer
            tvVertices[u.z] = f.z as integer
        )
        --> necessary as well as some models have isolated vertices...
        for i=1 to tvVertices.count do if (tvVertices[i] == undefined ) then tvVertices[i] = i as integer

        local tv_vertex_weight_list = #()
        for tv in tvVertices do
            append tv_vertex_weight_list vertex_weight_list[tv]
            
        local mtgcList = #()
        for tvw in vertex_weight_list do appendIfUnique mtgcList tvw.crc

        -->  GEOS.MATS.matrices
        for m in mtgcList do
        (
            local parts = filterstring m "|"
            for p in parts do
            (
                if p != "" then append weights.matrices (p as integer )
            )
        )

        --> GEOS.MTGC
        for m in mtgcList do
        (
            local parts = filterstring m "|"
            append weights.mtgc parts.count
        )

        --> GEOS.GNDX
        format "GNDX\n"
        for vw in tv_vertex_weight_list do
        (
            for m=1 to mtgcList.count do 
            (
                if mtgcList[m] == vw.crc then append weights.gndx m
            )
        )
        deselect theMesh
        return weights
    ),
    /* get the geometry sets from the scene */
    function GetGEOS mdx=
    (
        struct geo800  
            (   size, vrtx = #(), nrms = #(), ptyp, pcnt, pvtx = #(), gndx = #() , mtgc = #(), mats, uvas, uvbs = #(), meshRef,
                bones = #(),  --> bones indexes for weighing the vertices, vertices are equally weighted -> 2 bones => so 1 vertex is 0.5
                uniqueBoneIds = #() --> the list of bones required for this whole mesh
            )
        struct mats800 ( nbrItems, name, matrices = #(), materialId, sectionGroupId, sectionGroupType, sevenFloats = #(), nbrFloats, floats = #() )
            
        /* get the mesh references that can be exported */
        local geos = #()
        local mtls =  mdx.mtls
            
        for obj in objects do
        (
            if ( classof obj == editable_mesh ) then
            (
                if ( obj.ishidden == false ) then
                (
                    if ( classof obj.material == WarcraftIII_Standard or
                          ( 
                            classof obj.material == CompositeMaterial and 
                            classof obj.material.materialList[1] == WarcraftIII_Standard and
                            classof obj.material.materialList[2] == WarcraftIII_Standard 
                          )
                        ) then
                        (
                            local geo = geo800 meshRef:obj
                            append geos geo
                        )
                )
            )
        )
        
        /* for each mesh in this list of meshed do */
        for geo in geos do
        (
            format "Reading data from %\n" geo.meshRef.name
            local theMesh = geo.meshRef
            local original_vertices = #()
            local original_normals  = #()
            local weights  = Warcraft_III_Helpers.GetWeights theMesh mdx

            /* because a vertex can have multiple vertex coordinates keep track of them */
            for v=1 to theMesh.numVerts do
            (
                original_vertices[v] = getVert theMesh v
                original_normals[v]  = getNormal theMesh v
            )

            local tvVertices = #()
            local faces = #()
            for i=1 to theMesh.numFaces do
            (
                local f = getFace theMesh i
                local u = getTvFace theMesh i

                faces[i] = u
                tvVertices[u.x] = f.x
                tvVertices[u.y] = f.y
                tvVertices[u.z] = f.z
            )

            -- if there are isolated vertices, these will show up in the tvVertices as undefined -> fix this
            for i=1 to tvVertices.count do
            (
                if (tvVertices[i] == undefined ) then tvVertices[i] = i as float
            )
            
            local vertices = #()
            local normals = #()
            local uvs = #()
            for i=1 to tvVertices.count do
            (
                local uv = getTvert theMesh i
                
                if WC3_INVERT_UVW then 
                    uvs[i] = [uv.x, 1.0 - uv.y]
                else
                    uvs[i] = [uv.x, uv.y]
                
                vertices[i] = original_vertices[tvVertices[i]]
                normals[i]  = original_normals[tvVertices[i]]
            )
        
            geo.Size = 4 --> start initial size
            
            -- VRTX
            geo.Size += 8
            geo.vrtx = vertices --> vector 3
            geo.Size += vertices.count * 12
            
            -- NRMS
            geo.Size += 8
            geo.nrms = normals --> vector 3
            geo.Size += normals.count * 12
            
            -- PTYP --> type = triangle
            geo.Size += 12
            geo.ptyp = 0x4
            
            -- PCNT
            geo.Size += 12
            geo.pcnt = theMesh.numFaces * 3 --> number of corners or indices in the group
            
            -- PVTX
            geo.Size += 8
            for f=1 to faces.count do
            (
                local face = faces[f]
                append geo.pvtx [face.x - 1, face.y - 1, face.z - 1]
            )
            geo.Size += faces.count * 6
            
            -- UVAS / UVBS
            geo.Size += 8

            geo.uvas = 1 --help.GetNumUVMaps m
            for u=1 to geo.uvas do
            (
                geo.Size += 8
                geo.uvbs = uvs
                geo.Size += uvs.count * 8
            )
            
            -- MATS
            geo.Size += 8
            geo.mats = mats800()
            geo.mats.matrices = weights.matrices
            geo.Size += geo.mats.matrices.count * 4
            
            local theMaterial = undefined 
            for x=1 to mtls.count do
            (
                if ( theMesh.material.name == mtls[x].materialRef.name ) then 
                (
                    geo.mats.materialId = x - 1
                    theMaterial = mtls[x].materialRef
                )
            )
            
            geo.Size += 4 --> texture ID
            
            geo.mats.sectionGroupId = 0 --> always 0
            geo.mats.sectionGroupType = 0 --> if this would be an unselectable mesh, it should be 4
            
            if ( theMaterial != undefined and classof theMaterial != compositeMaterial ) then
                if theMaterial.ReplaceableTexture == 3 then geo.mats.sectionGroupType = 4
            
            geo.Size += 8 --> section group id, section group type
            
            local baseExtend = #()
            with animate on at time 0
            (
                local rad = distance theMesh.min theMesh.max
                append baseExtend rad
                append baseExtend theMesh.min.x
                append baseExtend theMesh.min.y
                append baseExtend theMesh.min.z
                append baseExtend theMesh.max.x
                append baseExtend theMesh.max.y
                append baseExtend theMesh.max.z
                geo.mats.sevenFloats = baseExtend
            )

            geo.Size += 7 * 4

            geo.Size += 4 --> one long --> nbr of seqs
            geo.mats.nbrFloats = mdx.SEQS.count
            
            for seqs in mdx.SEQS do
            (
                with animate on
                    at time seqs.startFrame
                    (
                        local extend = #()
                        local rad = distance theMesh.min theMesh.max
                        append Extend rad
                        append Extend theMesh.min.x
                        append Extend theMesh.min.y
                        append Extend theMesh.min.z
                        append Extend theMesh.max.x
                        append Extend theMesh.max.y
                        append Extend theMesh.max.z
                        
                        /* only when there is a scaling involved during certain animations, the extend is different */
                        local floatsToAdd = baseExtend
                        if ( matchpattern seqs.name pattern:"death*" or matchpattern seqs.name pattern:"dissipate" or matchpattern seqs.name pattern:"decay*" ) then 
                            floatsToAdd = Extend

                        for fl in floatsToAdd do append geo.mats.floats fl
                        
                    )
            )

            geo.Size += mdx.SEQS.count * 7 * 4
            
            -- GNDX
            geo.Size += 8
            geo.GNDX = weights.GNDX
            geo.Size += geo.gndx.count --> only byte
            
            -- MTGC
            geo.Size += 8
            geo.MTGC = weights.mtgc
            geo.Size += geo.MTGC.count * 4

        )
        
        mdx.geos = geos

    ),
    /* get the visibility tracks from each of the objects */
    function GetGEOA mdx=
    (
        mdx.geoa = #()
        struct geoa800 (size, opacity, geoId, color, type, KGAO)
        struct anim800 ( numPts, LineType = 0, glbsId = -1, KG = #() )
        struct kg800   ( Time, Point = 0.0, inTan, outTan, LineType = 0 )
    
        local seqs_frames = #()
        append seqs_frames 0
        for s in mdx.SEQS do append seqs_frames ( GriffonStudios_Helpers.RoundToFrame s.startframe )
        
        for g=1 to mdx.geos.count do
        (
            local geoa = geoa800 size:28 opacity:1.0 color:[1.0,1.0,1.0] type:0 geoId:(g - 1)
            local theMesh = mdx.geos[g].meshRef
            local visController = GetVisController theMesh
            local frames = undefined
            if (visController != undefined and classof visController == On_Off ) then 
            (
                frames = #()
                geoa.size += 16 --> KGAO, nbr of points, linetype, glbsId
                
                for key in visController.keys do append frames ( key.time as integer / TicksPerFrame )
                
                for f in seqs_frames do
                    appendIfUnique frames f
                
                frames = sort frames
                
                geoa.KGAO = anim800 numPts:frames.count

                geoa.size += geoa.KGAO.numPts * 8
                
                for f in frames do
                (
                    local kg = kg800()
                    at time f
                    (
                        kg.Time = f * 1000 / 30
                        if theMesh.visibility then kg.Point = 1.0
                    )
                    append geoa.KGAO.KG kg
                )
            )

            if WC3_MDX800_DEBUG then format " - %\n" geoa
            append mdx.geoa geoa
        )
        
    ),
    /* get the texture animation from the materials */ 
    function GetTXAN mdx=
    (
        struct txan800 ( size = 20, ktat )
        struct anim800 ( numPts, LineType, glbsId = -1, KG =#() )
        struct kg800   ( Time, Point )
        
        mdx.txan = #()

        local txanbIndex = 0
        for mtl in mdx.mtls do
        (
            local mat = mtl.materialRef
            local uniqueFrames = #()
            local txan = txan800()
            local foundTXAN = false
            
            if ( classof mat == WarcraftIII_Standard ) then
            (
                if ( not mat.diffuse_map.coords.u_offset.IsAnimated and not mat.diffuse_map.coords.v_offset.IsAnimated ) then continue 
                
                if ( mat.diffuse_map.coords.u_offset.IsAnimated ) then 
                    for key in mat.diffuse_map.coords.u_offset.controller.keys do appendifunique uniqueFrames key.time

                if ( mat.diffuse_map.coords.v_offset.IsAnimated ) then 
                    for key in mat.diffuse_map.coords.v_offset.controller.keys do appendifunique uniqueFrames key.time
                    
                foundTXAN = true
                uniqueFrames = sort uniqueFrames
                mtl.txanId = txanbIndex
                txanbIndex += 1
                local ktat = anim800 numPts:uniqueFrames.count LineType:( mat.LineType - 1 )
                
                for glbs in mdx.GLBS do
                (
                    for obj in glbs.objectList do
                    (
                        if ( obj.type == "material" and obj.objName == mat.name ) then ktat.glbsId = glbs.groupID - 1
                    )
                )
                    
                for frame in uniqueFrames do
                (
                    local kg = kg800()
                    
                    kg.Time = frame as integer / ticksperframe

                    at time frame 
                        kg.Point = [mat.diffuse_map.coords.u_offset, mat.diffuse_map.coords.v_offset, 0.0 ]
                    
                    append ktat.KG kg
                )
                txan.KTAT = ktat
            )
            
            if ( classof mat == CompositeMaterial ) then
            (
                for subMat in mat.materialList do
                if ( classof subMat == WarcraftIII_Standard ) then
                (
                    if ( not subMat.diffuse_map.coords.u_offset.IsAnimated and not subMat.diffuse_map.coords.v_offset.IsAnimated ) then continue 
                    
                    if ( subMat.diffuse_map.coords.u_offset.IsAnimated ) then 
                        for key in subMat.diffuse_map.coords.u_offset.controller.keys do appendifunique uniqueFrames key.time

                    if ( subMat.diffuse_map.coords.v_offset.IsAnimated ) then 
                        for key in subMat.diffuse_map.coords.v_offset.controller.keys do appendifunique uniqueFrames key.time
                      
                    foundTXAN = true
                    uniqueFrames = sort uniqueFrames
                    mtl.txanId = txanbIndex
                    txanbIndex += 1
                    local ktat = anim800 numPts:uniqueFrames.count LineType:subMat.LineType
                    
                    for glbs in mdx.GLBS do
                    (
                        for obj in glbs.objectList do
                        (
                            if ( obj.type == "material" and obj.objName == mat.name ) then ktat.glbsId = glbs.groupID - 1
                        )
                    )
                    
                    for frame in uniqueFrames do
                    (
                        local kg = kg800()
                        
                        kg.Time = frame as integer / ticksperframe

                        at time frame 
                            kg.Point = [subMat.diffuse_map.coords.u_offset, subMat.diffuse_map.coords.v_offset, 0.0 ]
                        
                        append ktat.KG kg
                    )
                    txan.KTAT = ktat
                )
            )
            if foundTXAN then (
                txan.size += txan.KTAT.KG.count * 16 
                append mdx.txan txan
            )
        )
        if ( WC3_MDX800_DEBUG ) then print mdx.txan
        
    ),
    /* get the bone animations AND helper animations */
    function GetObjects mdx=
    (
        struct object800 ( TotalSize = 0, ObjectType,  HeaderSize = 96, Id, parentId = -1, Name,  Flags, objRef, KGTR, KGRT, KGSC, geosetId = -1, geosetAnimationId = -1 )
     
        local allobjects = #() 
        local id = 0

        -- BONE
        for obj in objects do 
            if (classof obj == boneGeometry ) then
            (   
                local o = object800 Id:id Name:obj.name ObjectType:#wc3BONE Flags:0x100 objRef:obj TotalSize:96

                o.flags = Warcraft_III_Helpers.GetFlags o.flags obj
                
                id +=1
                append allObjects o
            )

        -- HELP
        for obj in objects do
            if (classof obj == Dummy or classof obj == SplineShape ) then
            (
                local o = object800 Id:id Name:obj.name ObjectType:#wc3HELP Flags:0x00 objRef:obj TotalSize:96
                id +=1
                append allObjects o
            )
        
        -- ATCH
        for obj in objects do
            if (classof obj == WarcraftIII_Attachment ) then 
            (
                local o = object800 Id:id Name:obj.name ObjectType:#wc3ATCH Flags:0x800 objRef:obj TotalSize:364
                id +=1
                append allObjects o
            )
        
        -- EVTS
        for obj in objects do
            if (classof obj == WarcraftIII_Event ) then
            (
                if ( obj.keyList.count > 0 ) then 
                (
                    local o = object800 Id:id Name:obj.name ObjectType:#wc3EVTS Flags:0x400 objRef:obj
                    id +=1
                    append allObjects o
                )
            )
            
        -- CLID
        for obj in objects do
            if ( getUserProp obj "COLLISION-OBJECT" != undefined and getUserProp obj "COLLISION-OBJECT" == true ) then
            (
                if ( classof obj == box or classof obj == sphere or classof obj == plane or classof obj == cylinder ) then
                (
                    local o = object800 Id:id Name:obj.name ObjectType:#wc3CLID Flags:0x2000 objRef:obj
                    id +=1
                    append allObjects o
                )
            )
        
        /* build the hierarchy of objects */
        for x=1 to allobjects.count do
        (
            if ( allobjects[x].objRef.parent != undefined ) then
            (
                for i=1 to allObjects.count do
                (
                    if allObjects[i].name == allObjects[x].objRef.parent.name then
                    (
                        allObjects[x].ParentId = allObjects[i].Id
                        exit
                    )
                )
                
            )
        )
        
        /* get the animations of these objects */
        for obj in allObjects do
        (
            local theGlbs = undefined
            local glbsId = -1
            local type = undefined
            if ( obj.objectType == #wc3Bone ) then type = "Bone"
            if ( obj.objectType == #wc3HELP ) then type = "Dummy"
            
            for glbs in mdx.glbs do 
            (
                for g in glbs.objectList do 
                (
                    
                    if ( g.type == (obj.objectType as string) and g.objName == obj.name ) then 
                    (
                        glbsId = glbs.groupID - 1
                        theGlbs = glbs
                        exit
                    )
                )
            )
            
            obj.KGTR = Warcraft_III_Helpers.GetKGTR obj.objRef --> translation
            obj.KGRT = Warcraft_III_Helpers.GetKGRT obj.objRef --> rotation
            obj.KGSC = Warcraft_III_Helpers.GetKGSC obj.objRef --> scale
            
            if obj.KGTR.nbrKeys > 0 then 
            (
                obj.TotalSize += obj.KGTR.Size
                if ( glbsId > -1 and theGlbs.OBJ_POSITION  ) then obj.KGTR.glbsId = glbsId
            )
            if obj.KGRT.nbrKeys > 0 then 
            (
                obj.TotalSize += obj.KGRT.Size
                if ( glbsId > -1 and theGlbs.OBJ_ROTATION  ) then obj.KGRT.glbsId = glbsId
            )
            if obj.KGSC.nbrKeys > 0 then 
            (
                obj.TotalSize += obj.KGSC.Size
                if ( glbsId > -1 and theGlbs.OBJ_SCALE  ) then obj.KGSC.glbsId = glbsId
            )
        )
        
        mdx.allObjects = allObjects
        
    ),
    function GetKGTR obj =
    (

        struct anim800   ( Size = 16, nbrKeys, Type = "KGTR", LineType=1, glbsId = -1, AnimBlock = #() )  
        struct KeyValuePair ( Key, Val )

        local cntrl = obj.pos.controller
        
        local classOfController = classof cntrl
        local lineType = 1
        if ( classOfController == Position_XYZ )     then lineType = 0x0
        if ( classOfController == linear_position )  then lineType = 0x1
        if ( classOfController == TCB_position )     then lineType = 0x2
        if ( classOfController == bezier_position )  then lineType = 0x3
        
        
        local pvt = at time 0f in coordsys parent obj.pos
        
        local kgtr = anim800 LineType:lineType
        
        local behaviorObj = Warcraft_III_Helpers.GetBehaviorObject()
        
        if behaviorObj != undefined then 
        (
            for glbs in behaviorObj do
            for b = 1 to glbs.objectList.count do
            if glbs.objectList[b].objName == obj.name then 
            ( 
                kgtr.glbsId = glbs.groupID - 1
                exit
            )
         
        )            
            
        kgtr.nbrKeys = numkeys cntrl
        kgtr.size += kgtr.nbrKeys * 16 --> framenbr, position
        
        for k in cntrl.keys do
        (
            local t = k.time as integer / TicksPerFrame
            
            local val = at time k.time in coordsys parent obj.pos
            val = val - pvt
            
            append kgtr.AnimBlock ( KeyValuePair Key:t Val:val )
        )
        return kgtr
    ),
    function GetKGRT obj =
    (
        struct anim800   ( Size = 16, nbrKeys, Type = "KGRT", LineType=1, glbsId = -1, AnimBlock = #() )  
        struct KeyValuePair ( Key, Val )

        local ctrl = obj.rotation.controller
        
        local classOfController = classof cntrl
        local lineType = 1
        if ( classOfController == Euler_XYZ )        then lineType = 0x0
        if ( classOfController == linear_Rotation )  then lineType = 0x1
        if ( classOfController == TCB_Rotation )     then lineType = 0x2
        if ( classOfController == bezier_Rotation )  then lineType = 0x3
        
        local kgrt =  anim800 LineType:lineType
        
        
        
        local rot = inverse obj.rotation

        local parentRot = quat 0 0 0 1
        
        if obj.parent != undefined then parentRot = inverse obj.parent.rotation
        
        kgrt.nbrKeys = numkeys ctrl
        kgrt.size += kgrt.nbrKeys * 20
         
        local behaviorObj = Warcraft_III_Helpers.GetBehaviorObject()
        
        if behaviorObj != undefined then 
        (
            for glbs in behaviorObj do
            for b = 1 to glbs.objectList.count do
            if glbs.objectList[b].objName == obj.name then 
            ( 
                kgtr.glbsId = glbs.groupID - 1
                exit
            )
        )   
               
        for key in ctrl.keys do
        (
            local t = key.time
            
            local val = undefined
            at time t
                val = obj.rotation * rot

            if ( obj.parent != undefined ) then
                at time t 
                    val = val / ( obj.parent.rotation * parentRot )
            
            append kgrt.AnimBlock ( KeyValuePair key:t val:val )
        )
        return kgrt
    ),
    function GetKGSC obj =
    (
        struct anim800   ( Size = 16, nbrKeys, Type = "KGSC", LineType=1, glbsId = -1, AnimBlock = #() )  
        struct KeyValuePair ( Key, Val )

        local classOfController = classof obj.scale.controller
        local lineType = 1
        if ( classOfController == ScaleXYZ )      then lineType = 0x0
        if ( classOfController == linear_Scale )  then lineType = 0x1
        if ( classOfController == TCB_Scale )     then lineType = 0x2
        if ( classOfController == bezier_Scale )  then lineType = 0x3

        local kgsc =  anim800 LineType = lineType
        
        kgsc.nbrKeys = numkeys obj.scale.controller
        kgsc.size += kgsc.nbrKeys * 16
           
        local behaviorObj = Warcraft_III_Helpers.GetBehaviorObject()
        
        if behaviorObj != undefined then 
        (
            for glbs in behaviorObj do
            for b = 1 to glbs.objectList.count do
            if glbs.objectList[b].objName == obj.name then 
            ( 
                kgtr.glbsId = glbs.groupID - 1
                exit
            )
        )   
        
        for k=1 to kgsc.nbrKeys do
        (
            local kv = KeyValuePair()
            kv.key =  ( getKeyTime obj.scale.controller k ) as integer / TicksPerFrame

            at time kv.key 
                kv.val = obj.scale

            append kgsc.AnimBlock kv
        )
        return kgsc
    ),
    function WriteVector3 stream vector3=
    (
         writeFloat stream vector3.X
         writeFloat stream vector3.Y
         writeFloat stream vector3.Z
        
        
    ),
    function WriteQuat stream quaternian=
    (
        writeFloat stream quaternian.x
        writeFloat stream quaternian.y
        writeFloat stream quaternian.z
        writeFloat stream quaternian.w

    ),
    function WriteKGAnim stream kgAnim=
    (
        if kgAnim == undefined then return undefined
        if ( kgAnim.nbrKeys > 0 ) then 
        (
            Warcraft_III_Helpers.WriteFixedString stream kgAnim.Type 4            
            writeLong stream kgAnim.nbrKeys
            writeLong stream kgAnim.lineType
            writeLong stream kgAnim.glbsId #signed
            
            for anim in kgAnim.AnimBlock do
            (
                
                local theKey = anim.Key * 1000 / 30
                writeLong stream theKey
                              
                if ( kgAnim.Type == "KGTR" ) then Warcraft_III_Helpers.WriteVector3 stream anim.Val
                if ( kgAnim.Type == "KGRT" ) then Warcraft_III_Helpers.WriteQuat    stream anim.Val 
                if ( kgAnim.Type == "KGSC" ) then Warcraft_III_Helpers.WriteVector3 stream anim.Val
                
            )
            
            
        )
        
        
    ),
    function GetBehavior=
    (
        local ret = undefined
        for obj in objects do 
            if (classof obj == WarcraftIII_Behavior ) then
            (
                ret = obj
                exit
            )
        return ret
    ),
    function ApplyUserProperties flags obj=
    (
        if ( bit.and flags 0x0008 > 0 ) then setUserProp obj "BILLBOARD" true
        if ( bit.and flags 0x0010 > 0 ) then setUserProp obj "BILLBOARD-LOCK-X" true
        if ( bit.and flags 0x0020 > 0 ) then setUserProp obj "BILLBOARD-LOCK-Y" true
        if ( bit.and flags 0x0040 > 0 ) then setUserProp obj "BILLBOARD-LOCK-Z" true
        if ( bit.and flags 0x2000 > 0 ) then setUserProp obj "COLLISION-OBJECT" true
    ),
    function GetFlags flags obj=
    (
        if ( getUserProp obj "BILLBOARD" == true ) then flags += 0x8
        if ( getUserProp obj "BILLBOARD-LOCK-X" == true ) then flags += 0x10
        if ( getUserProp obj "BILLBOARD-LOCK-Y" == true ) then flags += 0x20
        if ( getUserProp obj "BILLBOARD-LOCK-Z" == true ) then flags += 0x40
        
        return flags
    ),
    function ValidateMeshesForExport mdx=
    (
        local index = 0
        for obj in objects do
        (
            
            if classof obj != editable_mesh then continue
            format "Validating object %\n" obj.name
            
            index += 1
            -- unselect all selected sub object to prevent errors
            select obj
            max modify mode
            modPanel.setCurrentObject obj.baseObject
            subobjectLevel = 1
            deselect obj.selectedVertices
            subobjectLevel = 2
            deselect obj.selectedEdges
            subobjectLevel = 3
            deselect obj.selectedFaces
            subobjectLevel = 4
            deselect obj.selectedFaces
            subobjectLevel = 5
            deselect obj.selectedFaces
            subobjectLevel = 0

            -- primites without decent unwrapping tend to provide errors on unwrap modifiers
            select obj
            max modify mode
            local mshSkin = modPanel.getCurrentObject()
            local createDummyBone = false
            local addSkinMod = false
            
            -- this happens when there is a obj that you want exported but does not have any bones or skin modifier
            if ( classof mshSkin != skin ) then 
            (
                createDummyBone = true
                addSkinMod = true
            )
            
            -- this happens when there is a obj that you want exported but does not have any bones and has already a skin modifier
            if ( classof mshSkin == skin and skinOps.GetNumberBones mshSkin == 0 ) then 
                createDummyBone = true
            
            if ( createDummyBone ) then
            (
                local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
                aBone.Name = "TOBEDELETED_" + (index as string)
                aBone.Pos = obj.pos
                aBone.parent = obj.parent
                
                append mdx.autoCreatedObjectsForExport aBone
                
                select obj
                max modify mode
                    
                if addSkinMod then
                (
                    mshSkin = skin()
                    addmodifier obj mshSkin
                    
                    append mdx.autoCreatedObjectsForExport obj
                )

                modPanel.setCurrentObject mshSkin
                skinOps.addBone mshSkin aBone 0
                
                update obj
                
                for v=1 to obj.verts.count do
                    skinOps.ReplaceVertexWeights mshSkin v #(1) #(1.0)
                
                update obj
                
            )
            select obj
            modPanel.setCurrentObject obj.baseObject
            modPanel.addModToSelection (Unwrap_UVW ())
            obj.modifiers[#unwrap_uvw].unwrap.move ()
            maxOps.CollapseNodeTo obj 2 off
            
            clearSelection()

        )
    ),
    function CleanUpAfterExport mdx=
    (
        for obj in mdx.autoCreatedObjectsForExport do
        (
            
            if classof obj == editable_mesh then deleteModifier obj 1
            if classof obj == bonegeometry  then delete obj 
            
        )
        
    ),
    function EncodeBehaviorFlags mdx=
    (
        local listOfObjects = #()
        for glbs in mdx.glbs do
        (
            local str = ( glbs.groupId as string ) + "|" + ( glbs.nbrFrames as string ) + "|"
            for obj in glbs.objectList do
            (
                obj.flags = 0
                if ( obj.MATERIAL_UV )       then obj.flags += 0x01
                if ( obj.MATERIAL_ALPHA )    then obj.flags += 0x02
                if ( obj.MATERIAL_EMISSIVE ) then obj.flags += 0x04
                
                if ( obj.OBJ_POSITION )      then obj.flags += 0x10
                if ( obj.OBJ_ROTATION )      then obj.flags += 0x20
                if ( obj.OBJ_SCALE )         then obj.flags += 0x40
                if ( obj.VISIBILITY_TRACK )  then obj.flags += 0x80
            
                str += obj.objName + "|" + obj.type  + "|" + obj.flags as string + "|"
            )

            append listOfObjects str
        )
        
        return listOfObjects
    ),
    function DecodeBehaviorFlags mdx=
    (

    ),
    function DecodeFlags glbsObj=
    (
        if ( bit.and glbsObj.flags 0x01 > 0 ) then glbsObj.MATERIAL_UV = true
        if ( bit.and glbsObj.flags 0x02 > 0 ) then glbsObj.MATERIAL_ALPHA = true
        if ( bit.and glbsObj.flags 0x04 > 0 ) then glbsObj.MATERIAL_EMISSIVE = true
        if ( bit.and glbsObj.flags 0x10 > 0 ) then glbsObj.OBJ_POSITION = true
        if ( bit.and glbsObj.flags 0x20 > 0 ) then glbsObj.OBJ_ROTATION = true
        if ( bit.and glbsObj.flags 0x40 > 0 ) then glbsObj.OBJ_SCALE = true
        if ( bit.and glbsObj.flags 0x80 > 0 ) then glbsObj.VISIBILITY_TRACK = true
        
        return glbsObj
    ),
    
    
    function SortTrack dummy_track=
    (
        
        for t in dummy_track do
        for i=2 to dummy_track.count do
        (
            local tmp = dummy_track[i-1]
            if tmp.time > dummy_track[i].time then
            (
                dummy_track[i-1] = dummy_track[i]
                dummy_track[i] = tmp
            )
            
        )
        return dummy_track
    )
)
