
--[[
    Implementation of splay tree

    Reference
    https://www.sanfoundry.com/cpp-program-implement-splay-tree/
]]

--[[
    splay

    A single node in a splay tree
]]
local splay = {}
setmetatable(splay, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local splay_mt = {
    __index = splay;
}

function splay.new(self, key, lchild, rchild)
    local obj = {
        key = key;
        lchild = lchild;
        rchild = rchild;
    }
    setmetatable(obj, splay_mt)

    return obj
end

--[[
    Convenience functions for splaytree node
]]
local function RR_Rotate(k2)
    local k1 = k2.lchild
    k2.lchild = k1.rchild
    k1.rchild = k2

    return k1
end

local function LL_Rotate(k2)
    local k1 = k2.rchild;
    k2.rchild = k1.lchild
    k1.lchild = k2

    return k1
end

--[[
    SplayTree

    Primary object
]]
local SplayTree = {}
setmetatable(SplayTree, {
    __call = function(self, ...)
        return self:new(...)
    end;
})
local SplayTree_mt = {
    __index = SplayTree;
}

function SplayTree.new(self, ...)
    local obj = {
        p_node = nil;
    }
    setmetatable(obj, SplayTree_mt)

    return obj;
end

function SplayTree.splay(self, key, root)
    if not root then
        return nil;
    end

    local header = splay();
    header.lchild = nil;
    header.rchild = nil;

    local LeftTreeMax = header;
    local RightTreeMax = header;

    while true do
        if key < root.key then
            if not root.lchild then
                break;
            end

            if key < root.lchild.key then
                root = RR_Rotate(root)
                if not root.lchild then
                    break;
                end
            end

            -- Link to R Tree
            RightTreeMin.lchild = root
            RightTreeMin = RightTreeMin.lchild
            root = root.lchild;
            RightTreeMin.lchild = nil;
        elseif key > root.key then
            if not roo.rchild then
                break;
            end
            if key > root.rchild.key then
                root = LL_Rotate(root)
                if not root.rchild then
                    break;
                end
            end

            -- Link to L Tree
            LeftTreeMax.rchild = root
            LeftTreeMax = LeftTreeMax.rchild
            root = root.rchild
            LeftTreeMax.rchild = nil
        else
            break;
        end

    end

    -- Assemble L Tree, Middle Tree, and R tree
    LeftTreeMax.rchild = root.lchild;
    RightTreeMax.lchild = root.rchild;
    root.lchild = header.rchild;
    root.rchild = header.lchild;

    return root;
end

function SplayTree.newNode(self, key)
    local p_node = splay();
    
    assert(p_node ~= nil, "out of memory")

    
    p_node.key = key;
    p_node.lchild = nil;
    p_node.rchild = nil;
    
    return p_node;
end


function SplayTree.insert(self, key, root)
    if self.p_node == nil then
        self.p_node = self:newNode(key)
    else
        self.p_node.key = key
    end

    if not root then
        root = self.p_node;
        self.p_node = nil;
        return root
    end
    root = self:splay(key, root)

    if (key < root.key) then
        self.p_node.lchild = root.lchild;
        self.p_node.rchild = root;
        root.lchild = nil;
        root = self.p_node;
    elseif key > root.key then
        self.p_node.rchild = root.rchild;
        self.p_node.lchild = root 
        root.rchild = nil;
        root = self.p_node;
    else
        return root;
    end
    self.p_node = nil;

    return root
end

function SplayTree.delete(self, key, root)
    local temp
    if not root then
        return nil
    end

    root = self:splay(key, root);
    if key ~= root.key then
        return root
    else
        if root.lchild ~= nil then
            temp = root;
            root = root.rchild;
        else
            temp = root;
            root = self:splay(key, root.lchild)
            root.rchild = temp.rchild
        end
        return root
    end
end

function SplayTree.search(self, key, root)
    return self:Splay(key, root)
end

--[[
    Braindead simple Iterator
    This should turn into a real functional iterator
]]
function SplayTree.inOrder(self, root)
    if root then
        self:inOrder(root.lchild)
        io.write("key: ", root.key)
        if root.lchild then
            io.write(" | left child: ", root.lchild.key)
        end
        if root.rchild then
            io.write(" | right child: ", root.rchild.key)
        end
        print()

        self:inOrder(root.rchild)
    end
end

return SplayTree
